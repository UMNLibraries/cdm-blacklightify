# frozen_string_literal: true

module Umedia
  module Citation
    # Umedia::Citation::Cite
    class Cite
      attr_reader :mappings, :doc

      def initialize(mappings: [], doc: :MISSING_DOCUMENT)
        @mappings = mappings
        @doc = doc
      end

      def to_s
        mappings.map do |field|
          value = field_value(field)
          next unless value != false

          Field.new(prefix: field[:prefix],
                    suffix: field[:suffix],
                    formatters: field[:formatters],
                    value: value).to_s
        end.compact.join
      end

      def field_value(field)
        if field[:value]
          field[:value]
        elsif doc[(field[:name]).to_s].present?
          doc[(field[:name]).to_s]
        else
          false
        end
      end
    end
  end
end
