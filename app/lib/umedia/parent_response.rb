module Umedia
  class ParentResponse
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

    # add / set modifier
    def transcription_presence(item)
      response(item)['docs'][0]['transcription'].present? ? 'set' : 'add'
    end

    def response(item)
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'id:' + item.to_s,
        rows: '1000',
        sort: 'id asc',
        'hl.method': 'original',
        fl: 'transcription id'
      }).fetch('response', {})
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
