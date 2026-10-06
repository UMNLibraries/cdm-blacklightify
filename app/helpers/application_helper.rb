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
