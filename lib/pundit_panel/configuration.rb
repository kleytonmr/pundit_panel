# frozen_string_literal: true

module PunditPanel
  class Configuration
    attr_accessor :adapter,
                  :user_model,
                  :role_attribute,
                  :auth_method,
                  :authenticate_with,
                  :role_model,
                  :permission_model,
                  :user_role_model,
                  :permission_columns,
                  :user_roles_method,
                  :permission_check,
                  :layout

    def initialize
      @adapter           = :enum
      @user_model        = "User"
      @role_attribute    = :role
      @auth_method       = nil
      @authenticate_with = nil
      @role_model        = "Role"
      @permission_model  = "Permission"
      @user_role_model   = "UserRole"
      @user_roles_method = :roles
      @permission_check  = nil
      @layout            = "pundit_panel/application"

      # Maps semantic keys to actual column names on the permission model.
      #   policy_class: column that stores the policy class name (e.g. "DevicePolicy")
      #   action:       column that stores the action name (e.g. "index?")
      #   permitted:    boolean column — set to nil when presence of record = permitted
      @permission_columns = {
        policy_class: :policy_class,
        action:       :action,
        permitted:    :permitted
      }
    end

    def user_class
      @user_model.constantize
    end

    def role_class
      @role_model.constantize
    end

    def permission_class
      @permission_model.constantize
    end

    def user_role_class
      @user_role_model.constantize
    end

    def adapter_instance
      @adapter_instance ||= case @adapter.to_sym
                            when :enum  then Adapters::EnumAdapter.new(self)
                            when :table then Adapters::TableAdapter.new(self)
                            else raise PunditPanel::Error, "Unknown adapter: #{@adapter}. Use :enum or :table."
                            end
    end
  end
end
