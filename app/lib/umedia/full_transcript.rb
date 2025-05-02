# # frozen_string_literal: true

# module Umedia
#   # Umedia search configuration
#   # TODO: refactor item such that it can produce full compound data
#   # which means maybe bringing child_search and other dependencies into
#   # Item as well
#   class FullTranscript
#     attr_reader :item, :search_config, :child_search_klass
#     def initialize(
#                   # item: :MISSING_ITEM,
#                    item: 'p16022coll613:992',
#                    item_klass: Parhelion::Item,
#                    search_config: Umedia::SearchConfig,
#                    child_search_klass: ChildSearch)
#       @item          = item
#       @search_config = search_config
#       @child_search_klass = child_search_klass
#     end

#     def to_s
#       # if transcript field of parent is already populated, convert to string. else leave it empty and get the child transcripts  . .  ?
  
#       (transcript ? transcript.to_s : '') + child_transcripts
#     end

#     # private

#     def transcript
#       # item.field_transcription.value
#       item
#     end

#     def child_transcripts
#       children.map { |child| child.field_transcription.value }
#               .uniq
#               .reject(&:blank?)
#               .join(' ')
#     end

#     # the actual child searching part
#     def children
#       @child_search ||=
#         child_search_klass.new(parent_id: item,
#                                search_config: transcript_config).items
#     end

#     def transcript_config
#       search_config.new(
#         q: '*:*',
#         rows: '50000'
#       )
#     end
#   end
# end

module Umedia
  class FullTranscript
    attr_reader :item, :page, :rows, :solr_client
    def initialize(item: :MISSING_ITEM,
                   page: 1,
                   rows: 1000,
                   solr_client: blacklight_solr)
      @item = item
      @page = page
      @rows = rows
      @solr_client = solr_client
    end

    def child_transcripts(item)
      child_response(item)['docs'].map { |child| child['transcription'] }
                                  .uniq
                                  .reject(&:blank?)
                                  .join(' ')
    end
    
    def child_response(item)
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'parent_id:' + item.to_s,
        rows: '50000',
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        fl: 'transcription'
      }).fetch('response', {})
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
