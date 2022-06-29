# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # MlaUrlFormatter
      class MlaUrlFormatter
        def self.format(value)
          "umedia.lib.umn.edu/item/#{value}"
        end
      end

      # MlaDateFormatter
      class MlaDateFormatter
        def self.format(_value)
          Time.zone.now.strftime('%d %b %Y')
        end
      end

      # Mla
      class Mla
        def self.mappings
          [
            { name: 'creator_ssim', prefix: '', suffix: '.',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'title_ssi', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::ItalicizeFormatter] },
            { name: 'date_created_te_split', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'contributing_organization_ssi', prefix: ' ', suffix: ', ', formatters: [] },
            { name: 'id', prefix: '', suffix: '', formatters: [MlaUrlFormatter] },
            { name: 'id', prefix: ' Accessed ', suffix: '.', formatters: [MlaDateFormatter] }
          ]
        end
      end
    end
  end
end
