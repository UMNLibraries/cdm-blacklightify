# frozen_string_literal: true

module Umedia
  # Umedia search configuration
  # TODO: refactor item such that it can produce full compound data
  # which means maybe bringing child_search and other dependencies into
  # Item as well
  class FullTranscript
    attr_reader :item, :search_config, :child_search_klass
    def initialize(
                  # item: :MISSING_ITEM,
                   item: 'p16022coll613:992',
                   item_klass: Parhelion::Item,
                   search_config: Umedia::SearchConfig,
                   child_search_klass: ChildSearch)
      @item          = item
      @search_config = search_config
      @child_search_klass = child_search_klass
    end

    def to_s
      # if transcript field of parent is already populated, convert to string. else leave it empty and get the child transcripts  . .  ?
  
      (transcript ? transcript.to_s : '') + child_transcripts
    end

    # private

    def transcript
      # item.field_transcription.value
      item
    end

    def child_transcripts
      children.map { |child| child.field_transcription.value }
              .uniq
              .reject(&:blank?)
              .join(' ')
    end

    # the actual child searching part
    def children
      @child_search ||=
        child_search_klass.new(parent_id: item,
                               search_config: transcript_config).items
    end

    def transcript_config
      search_config.new(
        q: '*:*',
        rows: '50000'
      )
    end
  end
end
