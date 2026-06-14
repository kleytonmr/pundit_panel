# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module PunditPanel
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      class_option :adapter, type: :string, default: "enum", desc: "Adapter to use: enum or table"

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/pundit_panel.rb"
      end

      def copy_migrations
        if options[:adapter] == "enum"
          migration_template(
            "migrations/create_pundit_panel_permissions.rb.tt",
            "db/migrate/create_pundit_panel_permissions.rb"
          )
        end
      end

      def mount_engine
        route 'mount PunditPanel::Engine, at: "/pundit_panel"'
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
