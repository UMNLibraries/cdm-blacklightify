# frozen_string_literal: true

module Umedia
  # Adds a set_spec attribute to Spotlight::Exhibit and provides a method to find or create an exhibit by set_spec.
  module ExhibitExtensions
    extend ActiveSupport::Concern

    included do
      attr_accessor :set_spec
    end
  end
end
