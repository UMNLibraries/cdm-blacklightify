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

    def next_page
      page + 1
    end

    def empty?
      docs_with_transcripts.length <= 0
    end

    def ids
      docs_with_transcripts.map { |doc| doc['id'] }.join(' ')
    end

    # don't need the full_transcript bit . . .
    # replace full_transcript with child response transcripts collector thing . . .
    def docs_with_transcripts
      @docs_with_transcripts ||= items.map do |item|
        # with_transcript(item.doc_hash, full_transcript.new(item: item).to_s)

        # need to split the response into; doc, transcript to feed into with_transcript method
        # 1) item.doc_hash is just the solr response    
        # 2) full_transcript is the problem we are going to solve (i.e., get the transcripts . . .)    
        with_transcript(response, full_transcript.new(item: item).to_s)

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
      # docs.map { |doc| to_item(doc['id']) }

      # this returns the items (id) now . . . 
      # Umedia::IndexTranscripts.new.items.count is correct . . .
      docs.map { |doc| doc['id'] }
    end 

    def docs
      response.fetch('docs', [])
    end

    # 2025-04-30: don't need this? just doing parhelion things to get the children . . ?
    # i believe this is what i am trying to replace with a meethod that gets the children . . .
    # from above, items, map with id. now you have the id/s, look for the children. take the id and use as parent_id
    # not replace perse, argubly don't need this at all. it just looks in the cache first . . .
    # but if it's not getting anything from the cache(if empty), they what does it do?
    def to_item(id)
      Rails.cache.fetch("item/#{id}") do
        Umedia::ItemSearch.new(id: id).item
      end
    end

    def q
      # if set_spec; otherwise, return everything w/o matching (faster than *)
      set_spec ? "set_spec:#{set_spec}" : '*:*'
    end

    def parent_id
      # get the parent id, feed this to the child_response method . . . 
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

    # t e s t ing children
    # this returns 8 children based on the hard coded parent id . . .
    # need to GET the parent id . . .
    def child_response
      @response ||= solr_client.paginate(page, rows, 'select', params: {
        q: 'parent_id:p16022coll613:992',
        rows: '50000',
        hl: 'on',
        sort: 'child_index asc',
        'hl.method': 'original',
        # fq: ["parent_id:p16022coll613:992"]
      }).fetch('response', {})
    end
    # end t e s t ing

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
