# frozen_string_literal: true

# Gretel breadcrumbs integration for Spotlight 6.0.0.rc2
# Spotlight 6.0.0.rc2 calls add_breadcrumb but doesn't declare gretel as a dependency

Rails.application.config.to_prepare do
  # Directly define add_breadcrumb method on Spotlight::ApplicationController
  # to override/supplement any missing implementation
  Spotlight::ApplicationController.class_eval do
    def add_breadcrumb(name, url = nil)
      # Spotlight calls this to build breadcrumb trail
      # For now, silently ignore - breadcrumbs are cosmetic only
      # TODO: Integrate with Gretel for full breadcrumb rendering
    end
  end
end
