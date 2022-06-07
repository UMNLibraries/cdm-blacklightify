
# Transform a solr document to a React Citation Hash
class SolrToReactCitation
  attr_reader :solr_doc,
              :cite_details,
              :cite_citation,
              :cite_download,
              :cite_transcript

  def initialize(solr_doc: {},
                 cite_details: Umedia::CiteDetails,
                 cite_citation: Umedia::CiteCitation,
                 cite_download: Umedia::CiteDownload,
                 cite_transcript: Umedia::CiteTranscript)

    @solr_doc        = solr_doc
    @cite_details    = cite_details
    @cite_citation   = cite_citation
    @cite_download   = cite_download
    @cite_transcript = cite_transcript
  end

  def items
    transform.map { |item| (!item.empty?) ? item : nil }.compact
  end

  private

  def transform
    transformers.inject([]) { |tranformer| tranformer.new(solr_doc).to_hash }
  end

  def transformers
    [
      cite_details,
      cite_citation,
      cite_download,
      cite_transcript
    ]
  end
end
