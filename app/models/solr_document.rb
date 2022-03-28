# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Spotlight::SolrDocument

  include Spotlight::SolrDocument::AtomicUpdates


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def more_like_this
    mlt_response = Blacklight.default_index.connection.get 'mlt', params: {
      q: "id:#{RSolr.solr_escape(self.id)}",
      rows: 5
    }

    mlt_response['response']['docs'].map do |doc|
      SolrDocument.new(doc)
    end
  end

  def cdm_thumbnail
    collection, id = self.id.split(':')
    "https://cdm16022.contentdm.oclc.org/digital/api/singleitem/collection/#{collection}/id/#{id}/thumbnail"
  end
end
