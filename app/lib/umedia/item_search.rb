# frozen_string_literal: true

module Umedia
  # Umedia search configuration
  class ItemSearch
    attr_reader :id, :client, :item_klass
    def initialize(id: '',
                   client: blacklight_solr,
                   item_klass: Parhelion::Item)
      @id     = id
      @client = client
      @item_klass = item_klass
    end

    def item
      # @item ||= item_klass.new(doc_hash: response['response']['docs'].first)
      @item ||= item_klass.new(doc_hash: response['docs'].first)
    end

    def response
      client.new.solr.get 'document', params: { id: id }
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end

    private

    # def response
    #   client.new.solr.get 'document', params: { id: id }
    # end

    # def blacklight_solr
    #   Blacklight.default_index.connection
    # end
  end
end