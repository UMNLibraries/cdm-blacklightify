# frozen_string_literal: true

# ApplicationHelper
module ApplicationHelper
  include KalturaHelper
  include SpotlightHelper

  def thumbnail(*args)
    document = args[0]

    if document.is_a?(SolrDocument)
      image_tag(document.cdm_thumbnail)
    else
      image_tag('placeholder.png')
    end
  end

  ##
  # Generate a document path that preserves Spotlight context
  # If in Spotlight, returns /spotlight/:exhibit_id/catalog/:id
  # Otherwise returns /catalog/:id
  def context_aware_solr_document_path(document = nil, **options)
    doc_id = document.is_a?(SolrDocument) ? document.id : document
    
    if params[:exhibit_id].present?
      # In Spotlight context, build the path directly
      path = "/spotlight/#{params[:exhibit_id]}/catalog/#{doc_id}"
      path += "?fullscreen=true" if options[:fullscreen]
      path
    else
      # Regular catalog path
      solr_document_path(doc_id, **options)
    end
  end
end
