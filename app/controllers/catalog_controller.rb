# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
    config.show.document_presenter_class = ShowPresenter
    config.raw_endpoint.enabled = true

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
    config.index.title_field = 'title_ssi'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')
    config.add_sort_field 'date_created_sort_ssortsi desc, title_sort_ssortsi asc', label: 'Year (Newest first)'
    config.add_sort_field 'date_created_sort_ssortsi asc, title_sort_ssortsi asc', label: 'Year (Oldest first)'
    config.add_sort_field 'title_sort_ssortsi asc', label: 'Title (A-Z)'
    config.add_sort_field 'title_sort_ssortsi desc', label: 'Title (Z-A)'
    config.add_sort_field 'creator_sort_ssortsi asc', label: 'Creator (A-Z)'
    config.add_sort_field 'creator_sort_ssortsi desc', label: 'Creator (Z-A)'

    # FACETS
    # @TODO - Special Projects
    ## config.add_facet_field 'super_collection_name_ss', label: 'Special Projects',
    ##                        limit: 4, collapse: true

    # Contributing Organization / contributing_organization_ssi
    config.add_facet_field 'contributing_organization_ssi', label: 'Contributing Organization',
                                                            limit: 4, collapse: true

    # Collection / collection_name_ssi
    config.add_facet_field 'collection_name_ssi', label: 'Collection', limit: 4, collapse: true

    # Type / type_ssi
    config.add_facet_field 'type_ssi', label: 'Type', limit: 4, collapse: true

    # Format / format_name_ssimv
    config.add_facet_field 'format_name_ssimv', label: 'Format', limit: 4, collapse: true

    # Created / date_created_ssortsi
    config.add_facet_field 'date_ssi', label: 'Created', limit: 4, collapse: true

    # Subject / subject_ssim
    config.add_facet_field 'subject_ssim', label: 'Subject', limit: 4, collapse: true

    # Creator / creator_ssim
    config.add_facet_field 'creator_ssim', label: 'Creator', limit: 4, collapse: true

    # Publisher / publisher_ssi
    config.add_facet_field 'publisher_ssi', label: 'Publisher', limit: 4, collapse: true

    # Contributor / contributor_ssim
    config.add_facet_field 'contributor_ssim', label: 'Contributor', limit: 4, collapse: true

    # Language / language_ssi
    config.add_facet_field 'language_ssi', label: 'Language', limit: 4, collapse: true

    # SEARCH RESULTS FIELDS
    # Description
    config.add_index_field 'description_ts', label: 'Description'
    # Creator
    config.add_index_field 'creator_ssim', label: 'Creator'

    # Created
    config.add_index_field 'date_created_sort_ssortsi', label: 'Created'

    # Contributed By
    config.add_index_field 'contributor_ssim', label: 'Contributed By'

    # Last Updated
    config.add_index_field 'dmmodified_ssi', label: 'Last Updated'

    # Thumbnails
    config.index.thumbnail_field = :object_ssi

    # ITEM VIEW FIELDS
    # Title
    config.add_show_field 'title_ssi', label: 'Title', itemprop: 'title', type: :primary
    # Description
    config.add_show_field 'description_ts', label: 'Description', itemprop: 'description', type: :primary
    # Date Created
    config.add_show_field 'date_ssi', label: 'Date Created', itemprop: 'date_created', link_to_facet: true, type: :primary
    # Creator
    config.add_show_field 'creator_ssim', label: 'Creator', itemprop: 'creator', link_to_facet: true
    # Contributor
    config.add_show_field 'contributor_ssim', label: 'Contributor', itemprop: 'contributor', link_to_facet: true
    # // Physical Description
    # Item Type
    config.add_show_field 'type_ssi', label: 'Item Type', itemprop: 'type', link_to_facet: true, type: :phys_desc
    # Format
    config.add_show_field 'format_name_ssimv', label: 'Format', itemprop: 'format', link_to_facet: true, type: :phys_desc
    # Dimensions
    config.add_show_field 'dimensions_ssi', label: 'Dimensions', itemprop: 'dimensions', type: :phys_desc
    # // Topics
    # Subjects
    config.add_show_field 'subject_ssim', label: 'Subjects', itemprop: 'subject', link_to_facet: true, type: :topic
    # Language
    config.add_show_field 'language_ssim', label: 'Language', itemprop: 'subject', link_to_facet: true, type: :topic
    # // Geographic Location
    # City
    config.add_show_field 'city_ssim', label: 'City', itemprop: 'city', link_to_facet: true, type: :geo_loc
    # State
    config.add_show_field 'state_ssi', label: 'State', itemprop: 'state', link_to_facet: true, type: :geo_loc
    # Country
    config.add_show_field 'country_ssi', label: 'Country', itemprop: 'country', link_to_facet: true, type: :geo_loc
    # Continent
    config.add_show_field 'continent_tesim', label: 'Continent', itemprop: 'country', link_to_facet: true, type: :geo_loc
    # GeoNames URL
    # // Collection Information
    # Contributing Organization
    config.add_show_field 'contributing_organization_ssi', label: 'Contributing Organization', itemprop: 'contributing_organization', link_to_facet: true, type: :coll_info
    # Contact Information
    config.add_show_field 'contact_information_ssi', label: 'Contact Information', itemprop: 'contact_information', type: :coll_info
    # Fiscal Sponsor
    # config.add_show_field 'fiscal_sponsor_ssi', label: 'Fiscal Sponsor', itemprop: 'fiscal_sponsor', type: :coll_info
    # // Identifiers
    # Local Identifier
    config.add_show_field 'local_identifier_ssi', label: 'Local Identifier', itemprop: 'identifier', type: :identifiers
    # DLS Identifier
    config.add_show_field 'dls_identifier_te_split', label: 'DLS Identifier', itemprop: 'identifier', type: :identifiers
    # Persistent URL
    config.add_show_field 'persistent_url_ssi', label: 'Persistent URL', itemprop: 'persistent_url', type: :identifiers
    # // Can I Use It? (copyright statement)
    config.add_show_field 'local_rights_tesi', label: 'Copyright', itemprop: 'copyright', type: :use

    # View Helpers
    # config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
