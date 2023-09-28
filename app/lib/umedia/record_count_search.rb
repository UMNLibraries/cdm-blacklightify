module Umedia
  class RecordCountSearch
    attr_reader :solr, :include_children
    def initialize(solr: SolrClient.new.solr, include_children: false)
      @solr = solr
      @include_children = include_children
    end

    def count
      response["response"]["numFound"]
    end

    def response
      @response ||= solr.get 'select', params: search_params
    end

    def search_params
      include_children ? with_children_params : params
    end

    def params
      {
        :q => 'document_type:item && record_type:"primary"',
        rows: 0
      }
    end

    def with_children_params
      {
        :q => '!viewer_type:COMPOUND_PARENT_NO_VIEWER && document_type:item',
        rows: 0
      }
    end
  end
end
