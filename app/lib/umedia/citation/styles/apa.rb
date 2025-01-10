# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # ApaCreatedDateFormatter
      class ApaDateFormatter
        def self.format(_value)
          # approximate/best guest
          if _value.to_s.include? '?'
            'ca. ' + _value[0].to_s.gsub('?', '')
          # range
          elsif _value.to_s.scan(/(?=-)/).count == 1
            'ca. ' + _value[0].to_s
          # year only
          elsif _value[0].to_s.length == 4
            _value[0].to_s
          # iso8601 ?
          else
            "#{Date.parse(_value[0]).strftime('%Y, %B %d')}"
          end
        end
      end

      # ApaAccessedDateFormatter
      class ApaAccessDateFormatter
        def self.format(_value)
          Time.zone.now.strftime('%Y-%m-%d')
        end
      end

      # APA
      class Apa
        def self.mappings
          [
            { name: 'creator_ssim', prefix: '', suffix: '',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'date_created_ssim', prefix: ' (', suffix: ').',
              formatters: [ApaDateFormatter] },
            { name: 'title_ssi', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::ItalicizeFormatter] },
            # { name: 'contributing_organization_ssi', prefix: ' ', suffix: ', ', formatters: [] },
            { name: 'id', prefix: ' Accessed: ', suffix: '',
              formatters: [ApaAccessDateFormatter] },
            { name: 'id', prefix: ', from ', suffix: '',
              formatters: [Umedia::Citation::Formatters::UrlFormatter] }
          ]
        end
      end
    end
  end
end
