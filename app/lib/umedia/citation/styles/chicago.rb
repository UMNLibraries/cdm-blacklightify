# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # ChicagoDateFormatter
      class ChicagoDateFormatter
        def self.format(_value)
          Time.zone.now.strftime('%B %d, %Y')
        end
      end

      # Chicago
      class Chicago
        def self.mappings
          [
            { name: 'creator_ssim', prefix: '', suffix: '. ',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'date_created_te_split', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'title_ssi', prefix: '"', suffix: '." ', formatters: [] },
            { name: 'contributing_organization_ssi', prefix: ' ', suffix: ', ', formatters: [] },
            { name: 'id', prefix: 'Accessed ', suffix: '. ', formatters: [ChicagoDateFormatter] },
            { name: 'id', prefix: '', suffix: '', formatters: [Umedia::Citation::Formatters::UrlFormatter] }
          ]
        end
      end
    end
  end
end
