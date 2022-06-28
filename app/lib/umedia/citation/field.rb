# frozen_string_literal: true

module Umedia
  module Citation
    # Umedia::Citation::Field
    class Field
      attr_reader :prefix, :suffix, :formatters, :value

      def initialize(prefix: '', suffix: '', formatters: [], value: '')
        @prefix     = prefix
        @suffix     = suffix
        @formatters = formatters
        @value      = value
      end

      def to_s
        "#{prefix}#{formatted_value}#{suffix}"
      end

      def formatted_value
        formatters.reduce(value) { |val, formatter| formatter.format(val) }
      end
    end
  end
end
