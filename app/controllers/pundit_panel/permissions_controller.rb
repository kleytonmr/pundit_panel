# frozen_string_literal: true

module PunditPanel
  class PermissionsController < BaseController
    def index
      @roles    = current_adapter.roles
      @policies = PunditPanel::PolicyInspector.scan

      @matrix = build_matrix(@roles, @policies)

      render :index
    end

    # PATCH /pundit_panel/permissions/toggle
    def toggle
      role         = current_adapter.role_from_param(params[:role])
      policy_class = params[:policy_class]
      action       = params[:action]

      current_adapter.toggle!(role, policy_class, action)

      respond_to do |format|
        format.turbo_stream do
          permitted = current_adapter.permitted?(role, policy_class, action)
          render turbo_stream: turbo_stream.replace(
            cell_dom_id(params[:role], policy_class, action),
            partial: "pundit_panel/permissions/cell",
            locals: { role: role, role_param: params[:role], policy_class: policy_class, action: action, permitted: permitted }
          )
        end
        format.html { redirect_back fallback_location: pundit_panel.permissions_path }
      end
    end

    # PATCH /pundit_panel/permissions/update
    def update
      role         = current_adapter.role_from_param(params[:role])
      policy_class = params[:policy_class]
      action       = params[:action]
      permitted    = ActiveModel::Type::Boolean.new.cast(params[:permitted])

      if permitted
        current_adapter.grant!(role, policy_class, action)
      else
        current_adapter.revoke!(role, policy_class, action)
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            cell_dom_id(params[:role], policy_class, action),
            partial: "pundit_panel/permissions/cell",
            locals: { role: role, role_param: params[:role], policy_class: policy_class, action: action, permitted: permitted }
          )
        end
        format.html { redirect_back fallback_location: pundit_panel.permissions_path }
      end
    end

    private

    # Builds a nested hash: { policy_class => { action => { role => true/false } } }
    def build_matrix(roles, policies)
      if enum_adapter?
        PunditPanel::Permission.matrix_for(roles, policies)
      else
        policies.each_with_object({}) do |(policy_class, actions), matrix|
          matrix[policy_class] = actions.each_with_object({}) do |action, action_hash|
            action_hash[action] = roles.each_with_object({}) do |role, role_hash|
              role_hash[role] = current_adapter.permitted?(role, policy_class, action)
            end
          end
        end
      end
    end

    def enum_adapter?
      PunditPanel.config.adapter.to_sym == :enum
    end

    def cell_dom_id(role, policy_class, action)
      "permission_#{role}_#{policy_class}_#{action}".gsub("::", "_").gsub(/\W/, "_")
    end
  end
end
