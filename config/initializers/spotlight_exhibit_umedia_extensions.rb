# frozen_string_literal: true

# Adds a set_spec attribute to Spotlight::Exhibit and provides a method to find or create an exhibit by set_spec.
Rails.application.config.to_prepare do
  Spotlight::Exhibit.include Umedia::ExhibitExtensions
end
