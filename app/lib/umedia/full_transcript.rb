module Umedia
  class FullTranscript
    attr_reader :item, :page, :rows, :solr_client, :parent_response
    def initialize(
                   item: :MISSING_ITEM,
                   page: 1,
                   rows: 1000,
                   solr_client: blacklight_solr,
                   parent_response: ParentResponse)
      @item = item
      @page = page
      @rows = rows
      @solr_client = solr_client
      @parent_response = parent_response
    end

    def child_transcripts(item)
      meta = {
        'id' => item,
        'transcription' => 
          { solr_modifier(item) =>
            child_response(item)['docs'].map { |child| child['transcription'] }
              # .uniq
              # .reject(&:blank?)
              .join(' ')
          }
      }
    end

    def solr_modifier(item)
      parent_response.new.transcription_presence(item)
    end
    
    def child_response(item)
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'parent_id:' + item.to_s,
        rows: '50000',
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        fl: 'transcription translation parent_id'
      }).fetch('response', {})
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
