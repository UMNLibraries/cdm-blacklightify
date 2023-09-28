module Umedia
  # Provides a total count on a per-field basis
  class FacetCountSearch
    attr_reader :solr, :facet
    def initialize(facet: :MISSING_FACET, solr: SolrClient.new.solr)
      @solr = solr
      @facet = facet
    end

    def count
      response['facet_counts']['facet_fields'][facet].length / 2
    end

    def response
      @response ||= solr.get 'select', params:  params
    end

    def params
      {
        q: '*:*',
        rows: 0,
        facet: true,
        'facet.field': facet,
        'facet.limit': -1,
        fl: ''
      }
    end
  end
end
