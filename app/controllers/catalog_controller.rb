# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)

    config.view.gallery.document_component = Blacklight::Gallery::DocumentComponent
    # config.view.gallery.classes = 'row-cols-2 row-cols-md-3'
    config.view.masonry.document_component = Blacklight::Gallery::DocumentComponent
    config.view.slideshow.document_component = Blacklight::Gallery::SlideshowComponent
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')

    config.add_field_configuration_to_solr_request!

    # enable facets:
    # https://github.com/projectblacklight/spotlight/issues/1812#issuecomment-327345318

    # FACETS
    # Special Projects / super_collection_name_ss

    # Contributing Organization / contributing_organization_name_s
    config.add_facet_field 'contributing_organization_ssi', label: 'Contributing Organization', limit: 8,
                                                            collapse: false

    # Collection / collection_name_s
    config.add_facet_field 'collection_name_ssi', label: 'Collection', limit: 8, collapse: false

    # Type / types
    config.add_facet_field 'type_ssi', label: 'Type', limit: 8, collapse: false

    # Format / format_name
    config.add_facet_field 'format_name_ssimv', label: 'Format', limit: 8, collapse: false

    # Created / date_created_ss
    config.add_facet_field 'date_created_sort_ssortsi', label: 'Created', limit: 8, collapse: false

    # Subject / subject_ss
    config.add_facet_field 'subject_ssim', label: 'Subject', limit: 8, collapse: false

    # Creator / creator_ss
    config.add_facet_field 'creator_ssim', label: 'Creator', limit: 8, collapse: false

    # Publisher / publisher_s
    config.add_facet_field 'publisher_ssi', label: 'Publisher', limit: 8, collapse: false

    # Contributor / contributor_ss
    config.add_facet_field 'contributor_ssim', label: 'Contributor', limit: 8, collapse: false

    # Language / language
    config.add_facet_field 'language_ssi', label: 'Language', limit: 8, collapse: false

    config.add_facet_fields_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
