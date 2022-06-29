# frozen_string_literal: true

require_dependency Rails.root.join('app/lib/umedia/citation/formatters.rb')

module Umedia
  module Citation
    module Styles
      # Wikipedia
      class Wikipedia
        # WikiDateFormatter
        class WikiDateFormatter
          def self.format(_value)
            Time.zone.now.strftime('%d %b %Y')
          end
        end

        def self.mappings
          [
            { name: 'id', value: '<ref name="University of Minnesota"> {{', formatters: [] },
            { name: 'id', prefix: 'cite web | url=', suffix: ' |',
              formatters: [Umedia::Citation::Formatters::ItemUrlFormatter] },
            { name: 'type_ssi', prefix: ' | title= (', suffix: ') ',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'title_ssi', prefix: ' ', suffix: ',', formatters: [] },
            { name: 'date_created_te_split', prefix: '(', suffix: ')', formatters: [] },
            { name: 'creator', prefix: ' | author=', suffix: '',
              formatters: [Umedia::Citation::Formatters::CommaJoinFormatter] },
            { name: 'id', prefix: ' | accessdate=', suffix: '', formatters: [WikiDateFormatter] },
            { name: 'contributing_organization_ssi', prefix: ' | publisher=', suffix: '}} </ref>', formatters: [] }
          ]
        end
      end
    end
  end
end
