# frozen_string_literal: true

module PunditPanel
  module Adapters
    class TableAdapter < Base
      def roles
        @config.role_class.all
      end

      def permissions_for(role)
        @config.permission_class.where(permissible: role).map do |permission|
          {
            policy_class: permission.public_send(col(:policy_class)),
            action:       permission.public_send(col(:action)),
            permitted:    true
          }
        end
      end

      def grant!(role, policy_class, action)
        record = @config.permission_class.find_or_initialize_by(
          permissible: role,
          **lookup_attrs(policy_class, action)
        )
        record.public_send(:"#{col(:permitted)}=", true) if col(:permitted) && record.respond_to?(:"#{col(:permitted)}=")
        record.save!
      end

      def revoke!(role, policy_class, action)
        scope = @config.permission_class.where(permissible: role, **lookup_attrs(policy_class, action))
        if col(:permitted)
          scope.update_all(col(:permitted) => false)
        else
          scope.destroy_all
        end
      end

      def assign_role!(user, role_or_id)
        role = resolve_role(role_or_id)
        @config.user_role_class.find_or_create_by!(user: user, role: role)
      end

      def remove_role!(user, role)
        @config.user_role_class.where(user: user, role: resolve_role(role)).destroy_all
      end

      def user_role(user)
        user.public_send(@config.user_roles_method).first
      end

      def role_to_param(role)
        role.to_param.to_s
      end

      def role_from_param(param)
        @config.role_class.find(param)
      end

      def role_label(role)
        role.respond_to?(:name) ? role.name : role.to_s
      end

      def permitted?(user_or_role, policy_class, action)
        return @config.permission_check.call(user_or_role, policy_class.to_s, action.to_s) if @config.permission_check

        roles = if user_or_role.respond_to?(@config.user_roles_method)
                  user_or_role.public_send(@config.user_roles_method)
                else
                  Array(user_or_role)
                end

        roles.any? { |role| permission_exists?(role, policy_class, action) }
      end

      private

      # Returns the actual column name for a semantic key (:policy_class, :action, :permitted)
      def col(key)
        @config.permission_columns[key]
      end

      def lookup_attrs(policy_class, action)
        { col(:policy_class) => policy_class.to_s, col(:action) => action.to_s }
      end

      def permission_exists?(role, policy_class, action)
        scope = @config.permission_class.where(permissible: role, **lookup_attrs(policy_class, action))
        col(:permitted) ? scope.where(col(:permitted) => true).exists? : scope.exists?
      end

      def resolve_role(role_or_id)
        return role_or_id unless role_or_id.is_a?(String) || role_or_id.is_a?(Integer)

        @config.role_class.find(role_or_id)
      end
    end
  end
end
