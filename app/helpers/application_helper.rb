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

  def transform_browse_search_params(search_params)
    return search_params if search_params.blank?

    transformed_params = search_params.dup
    q_param = transformed_params[:q].to_s

    set_spec_match = q_param.match(/\bset_spec:([^\s]+)\b/)
    if set_spec_match
      set_spec = set_spec_match[1]
      collection_name = collection_name_from_set_spec(set_spec)

      if collection_name.present?
        new_q = q_param.sub(/\bset_spec:[^\s]+\b/, '').strip
        transformed_params[:q] = new_q.empty? ? nil : new_q
        
        transformed_params[:f] ||= {}
        transformed_params[:f][:collection_name_s] ||= []
        transformed_params[:f][:collection_name_s] << collection_name
      end
    end

    transformed_params
  end
end
