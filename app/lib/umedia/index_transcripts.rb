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
    def initialize(set_spec: false,
                   page: 1,
                   rows: 1000,
                   solr_client: SolrClient,
                   full_transcript: FullTranscript,
                   after_date: false)
      @set_spec = set_spec
      @page = page
      @rows = rows
      @solr_client = solr_client.new
      @full_transcript = full_transcript
      @after_date = after_date
    end

    def index!
      solr_client.add(docs_with_transcripts)
      Rails.logger.info "Enriched transcripts for items: #{ids}" unless empty?
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
      @docs_with_transcripts ||= items.map do |item|
        with_transcript(item.doc_hash, full_transcript.new(item: item).to_s)
      end.compact
    end

    def with_transcript(doc, transcript)
      sanitize(doc.merge('transcription' => transcript)) if transcript != ''
    end

    # Remove fields that are automatically created in Solr as copies of other
    # fields. See core/conf/schema.xml "copyfields to enhance exact matches
    # on certain fields". If we left these in, updates would not work.
    def sanitize(doc)
      doc.delete_if { |key, value| key =~ (/_(s|ss|t|)($|_$)/) }
    end

    def items
      docs.map { |doc| to_item(doc['id']) }
    end

    def docs
      response.fetch('docs', [])
    end

    def to_item(id)
      Rails.cache.fetch("item/#{id}") do
        Umedia::ItemSearch.new(id: id).item
      end
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
      @response ||= solr_client.solr.paginate(page, rows, 'search', params: {
        q: q + date_query,
        sort: 'id desc',
        fl: '*',
        fq: ['record_type:primary', '!page_count:0']
      }).fetch('response', {})
    end
  end
end
