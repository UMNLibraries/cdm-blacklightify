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
    def initialize(
                   set_spec: false,
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
      unless empty?
        solr_client.add(docs_with_transcripts)
        Rails.logger.info "Enriched transcripts for items: #{ids}"
      end
    end

    def next_page
      page + 1
    end

    def empty?
      docs_with_transcripts.length <= 0
    end

    def ids
      docs_with_transcripts.map { |doc| doc['id'] }.join(' ')
    end

    def docs_with_transcripts
      items.map do |item|
        full_transcript.new.child_transcripts
      end.compact
    end

    # may not need this? currently targeting the 'transcription' field very specifically
    def sanitize(doc)
      doc.delete_if { |key, value| key =~ (/_(s|ss|t|)($|_$)/) }
    end

    def items
      docs.map { |doc| doc['id'] }
    end 

    def docs
      response.fetch('docs', [])
    end

    def q
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

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
