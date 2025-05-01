# frozen_string_literal: true

module Umedia

  # (1) Search for primary records with children
  # (2) Get the transript data for children
  # (3) Save existing child transcript data to the parent's
  # transcription field to make all transcripts searchable in
  # via the main site search
  #
  # It might make more sense to simply index child pages as proper solr
  # nested children
  class IndexTranscripts
    attr_reader :set_spec, :page, :rows, :solr_client, :full_transcript, :after_date
    def initialize(set_spec: 'p16022coll613',
                   page: 1,
                   rows: 1000,
                   solr_client: blacklight_solr,
                   full_transcript: FullTranscript,
                   after_date: false)
      @set_spec = set_spec
      @page = page
      @rows = rows
      @solr_client = solr_client
      @full_transcript = full_transcript
      @after_date = after_date
    end

    def index!
      solr_client.add(docs_with_transcripts)
      Rails.logger.info "Enriched transcripts for items: #{ids}" unless empty?
    end

    # def next_page
    #   page + 1
    # end

    def empty?
      docs_with_transcripts.length <= 0
    end

    # rewrite this so the logger works correctly ?
    def ids
      docs_with_transcripts.map { |doc| doc['id'] }.join(' ')
    end

    # def docs_with_transcripts
    #   @docs_with_transcripts ||= items.map do |item|
    #     with_transcript(item.doc_hash, full_transcript.new(item: item).to_s)
    #   end.compact
    # end

    def with_transcript(doc, transcript)
      sanitize(doc.merge('transcription' => transcript)) if transcript != ''
    end

    def child_transcripts(item)
      child_response(item)['docs'].map { |child| child['transcription'] }
                                  .uniq
                                  .reject(&:blank?)
                                  .join(' ')
    end

    def sanitize(doc)
      doc.delete_if { |key, value| key =~ (/_(s|ss|t|)($|_$)/) }
    end

    # def items
    #   docs.map { |doc| to_item(doc['id']) }
    # end 

    # def docs
    #   response.fetch('docs', [])
    # end

    # def to_item(id)
    #   Rails.cache.fetch("item/#{id}") do
    #     Umedia::ItemSearch.new(id: id).item
    #   end
    # end

    def q
      # if set_spec; otherwise, return everything w/o matching (faster than *)
      set_spec ? "set_spec:#{set_spec}" : '*:*'
    end

    def date_query
      return '' unless after_date

      Rails.logger.info "Selecting transcripts for records on or after date #{after_date}"
      " AND date_modified:[#{after_date} TO #{Time.now.strftime('%Y-%m-%d')}]"
    end

    def response
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: q + date_query,
        sort: 'id desc',
        fl: '*',
        fq: ['record_type:primary', '!page_count:0']
      }).fetch('response', {})
    end

    # children getter
    def child_response(item)
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'parent_id:' + item.to_s,
        rows: '50000',
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        fl: 'transcription'
        # fq: ['id:p16022coll613\:984'],
      }).fetch('response', {})
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
