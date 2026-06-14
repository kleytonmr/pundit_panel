# frozen_string_literal: true

module PunditPanel
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :authenticate_pundit_panel!

    helper_method :current_adapter, :pundit_panel_config

    layout -> { pundit_panel_config.layout }

    private

    def authenticate_pundit_panel!
      if PunditPanel.config.auth_method.present?
        send(PunditPanel.config.auth_method)
      elsif PunditPanel.config.authenticate_with.present?
        PunditPanel.config.authenticate_with.call(self)
      else
        raise PunditPanel::NotConfiguredError, "No authentication method configured for PunditPanel. " \
          "Set config.auth_method or config.authenticate_with in your initializer."
      end
    end

    def current_adapter
      @current_adapter ||= PunditPanel.config.adapter_instance
    end

    def pundit_panel_config
      PunditPanel.config
    end
  end
end
