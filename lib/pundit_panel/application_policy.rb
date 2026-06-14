# frozen_string_literal: true

module PunditPanel
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      raise Pundit::NotAuthorizedError, "must be logged in" unless user

      @user   = user
      @record = record
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.end_with?("?")
        result = adapter&.permitted?(user, self.class.name, method_name.to_s)
        result.nil? ? false : result
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?("?") || super
    end

    private

    def adapter
      PunditPanel.config&.adapter_instance
    end
  end
end
