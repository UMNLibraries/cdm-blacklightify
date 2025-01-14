# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # # MlaUrlFormatter
      # class MlaUrlFormatter
      #   def self.format(value)
      #     "umedia.lib.umn.edu/item/#{value}"
      #   end
      # end

      # # MlaDateFormatter
      # class MlaDateFormatter
      #   def self.format(_value)
      #     Time.zone.now.strftime('%d %b %Y')
      #   end
      # end

      # Mla
      class Mla
        def self.mappings
          [
            { name: 'creator_ssim', prefix: '', suffix: '.',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'title_ssi', prefix: ' ', suffix: '.', 
              formatters: [Umedia::Citation::Formatters::ItalicizeFormatter] },
            { name: 'date_created_ssim', prefix: ' ', suffix: '.',
              formatters: [Umedia::Citation::Formatters::CreatedDateFormatter] },
            { name: 'parent_collection_name', prefix: ' ', suffix: '. ', formatters: [] },
            { name: 'contributing_organization', prefix: ' ', suffix: ' ', formatters: [] },
            { name: 'id', prefix: ' Accessed ', suffix: '',
              formatters: [Umedia::Citation::Formatters::AccessDateFormatter] },
            { name: 'id', prefix: ', ', suffix: '',
              formatters: [Umedia::Citation::Formatters::UrlFormatter] }
          ]
        end
      end
    end
  end
end
