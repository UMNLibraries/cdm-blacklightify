# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # ApaDateFormatter
      class ApaDateFormatter
        def self.format(_value)
          "(#{Date.parse('1995-10-12').strftime('%Y, %B %d')})"
        end
      end

      # APA
      class Apa
        def self.mappings
          [
            # { name: 'creator_ssim', prefix: ' ', suffix: '.', formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'date_created', prefix: ' ', suffix: '',
              formatters: [ApaDateFormatter] },
            { name: 'title_ssi', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::ItalicizeFormatter] },
            # { name: 'contributing_organization_ssi', prefix: ' ', suffix: ', ', formatters: [] },
            { name: 'id', prefix: ' Retrieved from ', suffix: '',
              formatters: [Umedia::Citation::Formatters::UrlFormatter] }
          ]
        end
      end
    end
  end
end
