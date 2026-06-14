# frozen_string_literal: true

module PunditPanel
  class PolicyInspector
    EXCLUDED_METHODS = (
      Object.instance_methods |
      BasicObject.instance_methods |
      Kernel.instance_methods
    ).map(&:to_s).to_set.freeze

    def self.policies
      found = []

      ObjectSpace.each_object(Class) do |klass|
        next unless klass.name&.end_with?("Policy")
        next if klass == PunditPanel::ApplicationPolicy
        next if defined?(::ApplicationPolicy) && klass == ::ApplicationPolicy

        is_subclass =
          (defined?(::ApplicationPolicy) && klass < ::ApplicationPolicy) ||
          klass < PunditPanel::ApplicationPolicy

        found << klass if is_subclass
      end

      found
    end

    def self.actions_for(policy_class)
      policy_class
        .public_instance_methods(false)
        .map(&:to_s)
        .select { |m| m.end_with?("?") && m != "respond_to_missing?" }
        .sort
    end

    def self.all
      policies
        .each_with_object({}) { |klass, hash| hash[klass.name] = actions_for(klass) }
        .sort
        .to_h
    end

    def self.scan
      if defined?(Rails)
        begin
          Rails.application.eager_load!
        rescue StandardError
          nil
        end
      end

      all
    end
  end
end
