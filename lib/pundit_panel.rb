# frozen_string_literal: true

require "pundit_panel/version"
require "pundit_panel/engine"
require "pundit_panel/configuration"
require "pundit_panel/policy_inspector"
require "pundit_panel/application_policy"
require "pundit_panel/adapters/base"
require "pundit_panel/adapters/enum_adapter"
require "pundit_panel/adapters/table_adapter"

module PunditPanel
  class Error < StandardError; end
  class NotConfiguredError < Error; end

  @configuration = nil

  class << self
    attr_accessor :configuration

    def configure
      self.configuration = Configuration.new
      yield(self.configuration)
      self.configuration
    end

    def config
      configuration
    end
  end
end
