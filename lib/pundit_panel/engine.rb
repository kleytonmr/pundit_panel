# frozen_string_literal: true

module PunditPanel
  class Engine < ::Rails::Engine
    isolate_namespace PunditPanel

    config.autoload_paths << Engine.root.join("app")

    config.generators do |g|
      g.orm :active_record, migration: true
    end

    initializer "pundit_panel.action_controller" do
      ActiveSupport.on_load(:action_controller_base) do
        if defined?(PunditPanel::Controller)
          include PunditPanel::Controller
        end
      end
    end
  end
end
