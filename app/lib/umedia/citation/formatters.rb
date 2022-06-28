# frozen_string_literal: true

module Umedia
  module Citation
    module Formatters
      # ItemUrlFormatter
      class ItemUrlFormatter
        def self.format(id)
          "http://umedia.lib.umn.edu/item/#{id}"
        end
      end

      # CommaJoinFormatter
      class CommaJoinFormatter
        def self.format(value)
          if value.respond_to?(:join)
            value.join(', ')
          else
            value
          end
        end
      end

      # ItalicizeFormatter
      class ItalicizeFormatter
        def self.format(value)
          "<i>#{value}</i>"
        end
      end

      # UrlFormatter
      class UrlFormatter
        def self.format(value)
          "https://umedia.lib.umn.edu/item/#{value}"
        end
      end

      # ExtractFormats
      class ExtractFormats
        def self.format(value)
          value.map { |format| format.split('|').first }.join(',')
        end
      end
    end
  end
end
