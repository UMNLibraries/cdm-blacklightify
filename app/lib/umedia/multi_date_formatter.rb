# frozen_string_literal: true

module Umedia
  # MultiDateFormatter
  class MultiDateFormatter
    def self.format(value)
      years = String(value).scan(/\d{4}/)
      years.size > 1 ? Range.new(*years).to_a : years
    end
  end
end
