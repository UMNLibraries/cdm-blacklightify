module Umedia
  class FullTranscript
    attr_reader :item, :page, :rows, :solr_client
    def initialize(
                   item: :MISSING_ITEM,
                   page: 1,
                   rows: 1000,
                   solr_client: blacklight_solr)
      @item = item
      @page = page
      @rows = rows
      @solr_client = solr_client
    end

    def child_transcripts(item)
      meta = {
        'id' => item,
        'transcription' => 
          { 'add' =>
            child_response(item)['docs'].map { |child| child['transcription'] }
              # .uniq
              # .reject(&:blank?)
              .join(' ')
          }
      }
    end
    
    def child_response(item)
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'parent_id:' + item.to_s,
        rows: '50000',
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        fl: 'transcription parent_id'
      }).fetch('response', {})
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
