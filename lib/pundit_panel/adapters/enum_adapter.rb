# frozen_string_literal: true

module PunditPanel
  module Adapters
    class EnumAdapter < Base
      def roles
        @config.user_class.send(@config.role_attribute.to_s.pluralize).keys
      end

      def permissions_for(role)
        PunditPanel::Permission.where(role: role.to_s).map do |permission|
          {
            policy_class: permission.policy_class,
            action: permission.action,
            permitted: permission.permitted
          }
        end
      end

      def grant!(role, policy_class, action)
        PunditPanel::Permission
          .find_or_create_by!(role: role.to_s, policy_class: policy_class.to_s, action: action.to_s)
          .update!(permitted: true)
      end

      def revoke!(role, policy_class, action)
        PunditPanel::Permission
          .find_or_create_by!(role: role.to_s, policy_class: policy_class.to_s, action: action.to_s)
          .update!(permitted: false)
      end

      def assign_role!(user, role)
        user.update!(@config.role_attribute => role)
      end

      def user_role(user)
        user.send(@config.role_attribute)
      end

      def permitted?(user_or_role, policy_class, action)
        role = user_or_role.respond_to?(@config.role_attribute) \
          ? user_or_role.send(@config.role_attribute).to_s \
          : user_or_role.to_s
        PunditPanel::Permission.permitted?(role, policy_class.to_s, action.to_s)
      end
    end
  end
end
