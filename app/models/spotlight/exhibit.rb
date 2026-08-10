# frozen_string_literal: true

module Spotlight
  class Exhibit < ActiveRecord::Base
    # Just a monkey patch of Spotlight::Exhibit to add a set_spec attribute
    attr_reader :set_spec
  end
end
