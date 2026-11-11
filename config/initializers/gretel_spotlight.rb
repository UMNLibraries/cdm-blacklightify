# frozen_string_literal: true

# Gretel breadcrumbs integration for Spotlight 6.0.0.rc2
# Spotlight 6.0.0.rc2 calls add_breadcrumb but doesn't declare gretel as a dependency
# This initializer creates a no-op shim for add_breadcrumb to prevent errors

Rails.application.config.after_initialize do
  # Add a simple no-op breadcrumb method to Spotlight controllers
  # Breadcrumbs are cosmetic UI only - we can safely ignore them for now
  # A complete implementation would integrate Gretel, but that requires
  # additional view-layer setup and a breadcrumbs.rb config file
  
  Spotlight::ApplicationController.send(:define_method, :add_breadcrumb) do |name, url = nil|
    # No-op: breadcrumbs not yet implemented for BL8/Spotlight 6.0.0.rc2
    # This prevents NoMethodError while keeping Spotlight working
  end
end


