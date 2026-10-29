# frozen_string_literal: true

# ApplicationHelper
module ApplicationHelper
  include BlacklightHelper
  include KalturaHelper
  include SpotlightHelper

  def opensearch_description_tag(title, href)
    tag :link, href: href, title: title, type: "application/opensearchdescription+xml", rel: "search"
  end

  def render_search_bar
    render((blacklight_config&.view_config(document_index_view_type)&.search_bar_component || Blacklight::SearchBarComponent).new(
             url: search_action_url,
             advanced_search_url: search_action_url(action: 'advanced_search'),
             params: search_state.params_for_search.except(:qt),
             autocomplete_path: suggest_index_catalog_path
           ))
  end

  def render_index_field_label(document = nil, label: nil, field: nil)
    label || field&.humanize || 'Label'
  end

  def render_document_show_field_label(document = nil, label: nil, field: nil)
    label || field&.humanize || 'Label'
  end

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
    doc_id = extract_document_id(document)
    
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

  ##
  # Check if a CDM IIIF manifest is accessible
  def cdm_manifest_available?(doc_id)
    manifest_url = "https://cdm16022.contentdm.oclc.org/iiif/2/#{doc_id}/manifest.json"
    begin
      response = Net::HTTP.get_response(URI(manifest_url))
      response.is_a?(Net::HTTPSuccess)
    rescue StandardError
      false
    end
  end

  ##
  # Check if a local IIIF manifest is accessible
  def local_manifest_available?(doc_id)
    manifest_url = "/iiif/#{doc_id}/text/manifest.json"
    begin
      response = Net::HTTP.get_response(URI("http://localhost:3000#{manifest_url}"))
      response.is_a?(Net::HTTPSuccess)
    rescue StandardError
      false
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

  private

  # Extract document ID from various object types
  # Handles: SolrDocument, presenter objects, strings, and scalar IDs
  def extract_document_id(document)
    case document
    when SolrDocument
      document.id
    when String, Integer
      document
    when nil
      nil
    else
      # Handle presenter objects or other objects with .id method
      document.respond_to?(:id) ? document.id : document.to_s
    end
  end
end