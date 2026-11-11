# frozen_string_literal: true

# Gretel breadcrumbs configuration for Spotlight 6.0.0.rc2
# Spotlight calls add_breadcrumb dynamically instead of using Gretel's DSL,
# so this file mostly remains empty. Gretel still requires this file to exist.

crumb :root do
  link "Home", root_path
end
