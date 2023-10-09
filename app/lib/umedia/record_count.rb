module Umedia
  class RecordCount
    def collection_count
      blacklight_solr.get('select', :params => collection_params)['facet_counts']['facet_fields']['collection_name']
    end

    def item_count
      blacklight_solr.get('select', :params => primary_records_params)["response"]["numFound"]
    end

    def page_count
      blacklight_solr.get('select', :params => page_params)["response"]["numFound"]
    end

    def collection_params
      {
        :q => "*:*",
        :rows => '0', 
        :facet => true, 'facet.field': 'collection_name', 'facet.limit': -1, fl: ''
      }
    end

    def page_params
      {
        :q => '!viewer_type:COMPOUND_PARENT_NO_VIEWER && document_type:item',
        :rows => '0'
      }
    end

    def primary_records_params
      {
        :q => 'document_type:item && record_type:"primary"',
        :rows => '0'
      }
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
