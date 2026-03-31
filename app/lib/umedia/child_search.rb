# frozen_string_literal: true

module Umedia
  # Search for Child records
  class ChildSearch
    extend Forwardable

    def_delegators :@search_config, :page, :rows, :hash

    attr_reader :search_config, :parent_id, :client, :item_list_klass, :include_attachments

    def initialize(parent_id: :MISSING_PARENT_ID,
                   search_config: Parhelion::SearchConfig,
                   client: SolrClient,
                   item_list_klass: Parhelion::ItemList,
                   include_attachments: true)

      raise_missing(parent_id, :MISSING_PARENT_ID)

      @search_config = search_config
      @parent_id = parent_id
      @include_attachments = include_attachments
      @client = client
      @item_list_klass = item_list_klass
    end

    def raise_missing(arg, cond)
      raise ArgumentError.new("Required Argument: #{arg}") if arg == cond
    end

    def empty?
      num_found == 0
    end

    def num_found
      response['response']['numFound']
    end

    def items
      item_list_klass.new(results: response['response']['docs'])
    end

    def highlighting
      response['highlighting']
    end

    private

    def response
      @response ||= client.new.solr.paginate page, rows, 'child_search', params: params
    end

    def default_fq
      if include_attachments
        ["parent_id:\"#{parent_id}\""]
      else
        ["parent_id:\"#{parent_id}\"", '-attachment_format:[* TO *]']
      end
    end

    def params
      search_config.to_h.merge(
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        fq: search_config.fq + default_fq
      )
    end
  end
end
