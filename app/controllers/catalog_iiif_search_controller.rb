# frozen_string_literal: true

# catalog controller for iiif_search routes, which are not part of the main catalog controller
class CatalogIiifSearchController < ApplicationController
  include Blacklight::Catalog
  
  # CatalogController-scope behavior and configuration for BlacklightIiifSearch
  include BlacklightIiifSearch::Controller

  before_action :permit_language

  configure_blacklight do |config|
    # configuration for Blacklight IIIF Content Search
    config.iiif_search = {
      full_text_field: 'transcription_tesi',
      object_relation_field: 'parent_id',
      supported_params: %w[q page],
      autocomplete_handler: 'iiif_suggest',
      suggester_name: 'iiifSuggester',
    }

    # Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*',
      hl: true,
      'hl.method': 'original',
      'hl.fl': 'collection_* format_* subject title ',
      'hl.preserveMulti': false,
      'hl.simple.pre': '<span style=\'background-color: #ffde7a\'>',
      'hl.simple.post': '</span>'
    }

    config.document_solr_path = 'select'
    config.document_unique_id_param = 'ids'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields') do |field|
      field.solr_parameters = {
        fq: 'record_type:primary'
      }
    end

    # add facet field to allow Blacklight to pass the intended search parameters to Solr. field matches config.iiif_search object_relation_field above
    config.add_facet_field 'parent_id', include_in_request: false
  end

  def bad_request_no_search
    head :bad_request
  end

  # Allow the language parameter in controller actions
  def permit_language
    params.permit(:language)
  end
end
