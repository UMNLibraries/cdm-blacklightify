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

      # CreatedDateFormatter
      class CreatedDateFormatter
        def self.format(_value)
          # approximate/best guest
          if _value.to_s.include? '?'
            _value[0].to_s.gsub('?', '')
          # range
          elsif _value.to_s.scan(/(?=-)/).count == 1
            _value[0].to_s
          # year only
          elsif _value[0].to_s.length == 4
            _value[0].to_s
          # iso8601 ?
          else
            "#{Date.parse(_value[0]).strftime('%d %B %Y')}"
          end
        end
      end

      # AccessDateFormatter
      class AccessDateFormatter
        def self.format(_value)
          Time.zone.now.strftime('%b %d, %Y')
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
