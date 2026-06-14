# frozen_string_literal: true

module PunditPanel
  class Permission < ApplicationRecord
    self.table_name = "pundit_panel_permissions"

    validates :role, presence: true
    validates :policy_class, presence: true
    validates :action, presence: true, uniqueness: { scope: [:role, :policy_class] }

    scope :for_role,        ->(role) { where(role: role.to_s) }
    scope :permitted_only,  -> { where(permitted: true) }

    def self.permitted?(role, policy_class, action)
      where(role: role.to_s, policy_class: policy_class.to_s, action: action.to_s, permitted: true).exists?
    end

    # Returns { policy_class => { action => { role => boolean } } }
    # so the view can iterate policies → actions → roles uniformly.
    def self.matrix_for(roles, policies_hash)
      policies_hash.each_with_object({}) do |(policy_class, actions), matrix|
        policy_name = policy_class.to_s
        matrix[policy_name] = actions.each_with_object({}) do |action, action_map|
          action_str = action.to_s
          action_map[action_str] = roles.each_with_object({}) do |role, role_map|
            role_map[role] = permitted?(role.to_s, policy_name, action_str)
          end
        end
      end
    end
  end
end
