# frozen_string_literal: true

module PunditPanel
  class UsersController < BaseController
    def index
      base_scope = PunditPanel.config.user_class.order(:id)

      @users = if base_scope.respond_to?(:page)
                 base_scope.page(params[:page])
               else
                 base_scope.limit(50)
               end

      @roles = current_adapter.roles

      render :index
    end

    def update_role
      @user = PunditPanel.config.user_class.find(params[:id])

      if enum_adapter?
        current_adapter.assign_role!(@user, params[:role])
      else
        current_adapter.assign_role!(@user, params[:role_id] || params[:role])
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "user_#{@user.id}",
            partial: "pundit_panel/users/user",
            locals: { user: @user, roles: current_adapter.roles, idx: 0 }
          )
        end
        format.html { redirect_back fallback_location: pundit_panel.users_path }
      end
    end

    private

    def enum_adapter?
      PunditPanel.config.adapter.to_sym == :enum
    end
  end
end
