# frozen_string_literal: true

module PunditPanel
  module Adapters
    class Base
      def initialize(config)
        @config = config
      end

      def roles
        raise NotImplementedError, "#{self.class}#roles must be implemented"
      end

      def permissions_for(role)
        raise NotImplementedError, "#{self.class}#permissions_for must be implemented"
      end

      def grant!(role, policy_class, action)
        raise NotImplementedError, "#{self.class}#grant! must be implemented"
      end

      def revoke!(role, policy_class, action)
        raise NotImplementedError, "#{self.class}#revoke! must be implemented"
      end

      def toggle!(role, policy_class, action)
        if permitted?(role, policy_class, action)
          revoke!(role, policy_class, action)
        else
          grant!(role, policy_class, action)
        end
      end

      def assign_role!(user, role)
        raise NotImplementedError, "#{self.class}#assign_role! must be implemented"
      end

      def remove_role!(user, role)
        raise NotImplementedError, "#{self.class}#remove_role! must be implemented"
      end

      def user_role(user)
        raise NotImplementedError, "#{self.class}#user_role must be implemented"
      end

      def permitted?(user_or_role, policy_class, action)
        raise NotImplementedError, "#{self.class}#permitted? must be implemented"
      end

      # Serializes a role to a URL-safe param for use in form hidden fields.
      def role_to_param(role)
        role.to_s
      end

      # Resolves a param (from a form submission) back to a usable role value.
      def role_from_param(param)
        param
      end

      # Returns a human-readable label for a role.
      def role_label(role)
        role.respond_to?(:name) ? role.name : role.to_s.humanize
      end
    end
  end
end
