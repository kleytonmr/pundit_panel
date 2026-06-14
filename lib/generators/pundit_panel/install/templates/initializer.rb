# frozen_string_literal: true

PunditPanel.configure do |config|
  # Adapter to use for role resolution.
  #   :enum  — single enum column on the user model (migration generated automatically)
  #   :table — separate Role, Permission, and UserRole models already in your app
  config.adapter = :<%= options[:adapter] %>

  # The model that represents authenticated users and carries role information.
  # Examples: "User", "Admin"
  config.user_model = "User"

  # The before_action method used to protect the PunditPanel engine routes.
  # This method must be defined (or inherited) in your ApplicationController.
  # Examples: :authenticate_user! (Devise), :authenticate_admin!
  config.auth_method = :authenticate_user!

  # Alternative: use a lambda instead of a named before_action
  # config.authenticate_with = ->(controller) { controller.redirect_to "/login" unless controller.current_user }
<% if options[:adapter].to_s == "enum" %>
  # The enum attribute on your user model that stores the role.
  # Requires: enum :role, { viewer: 0, editor: 1, admin: 2 } on the model.
  config.role_attribute = :role
<% elsif options[:adapter].to_s == "table" %>
  # Models that already exist in your app.
  config.role_model       = "Role"
  config.permission_model = "Permission"
  config.user_role_model  = "UserRole"

  # Method called on the user object to retrieve their roles.
  # Default: :roles — change if your association has a different name.
  # config.user_roles_method = :roles

  # Maps semantic keys to the actual column names on your Permission model.
  # Defaults match the most common convention. Override only what differs.
  #
  #   policy_class: column storing the policy class name (e.g. "DevicePolicy")
  #   action:       column storing the action name (e.g. "index?")
  #   permitted:    boolean column — set to nil if record presence = permitted
  #
  # Examples:
  #   Standard app (policy_class, action, permitted columns — no change needed):
  #     config.permission_columns = { policy_class: :policy_class, action: :action, permitted: :permitted }
  #
  #   Atlas-style (record_name, resource columns, no boolean flag):
  #     config.permission_columns = { policy_class: :record_name, action: :resource, permitted: nil }
  #
  #   Custom app:
  #     config.permission_columns = { policy_class: :subject, action: :verb, permitted: :allowed }
  config.permission_columns = { policy_class: :policy_class, action: :action, permitted: :permitted }

  # For complex permission logic (e.g. multiple CRUD flags per permission),
  # bypass the default lookup entirely with a custom lambda:
  # config.permission_check = ->(user, policy_class, action) {
  #   Permission.where(permissible: user.roles, record_name: policy_class)
  #             .any? { |p| p.can_read? }
  # }
<% end %>
end
