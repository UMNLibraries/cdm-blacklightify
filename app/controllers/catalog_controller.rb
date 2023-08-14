# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Thumbnail

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
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
      fl: '*',
      fq: 'record_type_ssi:primary'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'title_ssi'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

		# additional targeted search query field. 
		config.add_search_field 'type_ssi', label: 'Type'
		config.add_search_field 'date_ssi', label: 'Date'
		config.add_search_field('subject') do |field|
      field.query_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.query_local_parameters = { 
        :qf => 'subject_ssim'
      }
    end
    
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
    config.add_index_field 'sp_description_ts', label: 'Description (Spanish)'
    # Creator
    config.add_index_field 'creator_ssim', label: 'Creator'

    # Created
    config.add_index_field 'date_created_sort_ssortsi', label: 'Created'

    # Contributed By
    config.add_index_field 'contributor_ssim', label: 'Contributed By'

    # Last Updated
    config.add_index_field 'dmmodified_ssi', label: 'Last Updated'

    config.add_index_field 'child_index_isi', label: 'Child Index'

    # Thumbnails - A helper method that looks for attached image from solr_document_sidecar
    config.index.thumbnail_method = :thumbnail

    # ITEM VIEW FIELDS
    config.add_show_field 'object_ssi', label: 'Thumbnail Source', itemprop: 'object'
    # Description
    config.add_show_field 'description_ts', label: 'Description', itemprop: 'description', type: :primary
    config.add_show_field 'sp_description_ts', label: 'Description (Spanish)', itemprop: 'description_sp', type: :primary
    # Date Created
    config.add_show_field 'date_created_sort_ssortsi', label: 'Date Created', itemprop: 'date_created',
                                                       link_to_facet: true, type: :primary
    # Creator
    config.add_show_field 'creator_ssim', label: 'Creator', itemprop: 'creator', link_to_facet: true, type: :primary

    ## Physical Description
    # Item Type
    config.add_show_field 'type_ssi', label: 'Type', itemprop: 'type', link_to_facet: true, type: :phys_desc
    # Format
    config.add_show_field 'format_ssim', label: 'Format', itemprop: 'format', link_to_facet: true, type: :phys_desc
    config.add_show_field 'sp_physical_format_ssi', label: 'Format (Spanish)', itemprop: 'format_sp', link_to_facet: false, type: :phys_desc

    ## Topics
    # Subjects
    config.add_show_field 'subject_ssim', label: 'Subject', itemprop: 'subject', link_to_facet: true, type: :topic
    config.add_show_field 'sp_subject_ssim', label: 'Subject (Spanish)', itemprop: 'subject_sp', link_to_facet: false, type: :topic
    # Language
    config.add_show_field 'language_ssi', label: 'Language', itemprop: 'language', link_to_facet: true, type: :topic
    config.add_show_field 'sp_language_ssi', label: 'Language (Spanish)', itemprop: 'language_sp', link_to_facet: false, type: :topic

    ## Geographic Location
    # Country
    config.add_show_field 'country_ssi', label: 'Country', itemprop: 'country', link_to_facet: true, type: :geo_loc
    config.add_show_field 'sp_country_ssi', label: 'Country (Spanish)', itemprop: 'country_sp', link_to_facet: false, type: :geo_loc

    config.add_show_field 'continent_ssi', label: 'Continent', itemprop: 'continent', link_to_facet: true, type: :geo_loc
    config.add_show_field 'sp_continent_ssi', label: 'Continent (Spanish)', itemprop: 'continent_sp', link_to_facet: false, type: :geo_loc

    ## Collection Information
    # Parent Collection
    config.add_show_field 'collection_name_ssi', label: 'Parent Collection', itemprop: 'parent_collection_name',
                                                 link_to_facet: true, type: :coll_info
    # Contributing Organization
    config.add_show_field 'contributing_organization_ssi', label: 'Contributing Organization',
                                                           itemprop: 'contributing_organization', link_to_facet: true, type: :coll_info
    # config.add_show_field 'contributing_organization_name_ssi', label: 'Contributing Organization',
    #                                                        itemprop: 'contributing_organization_name', link_to_facet: true, type: :coll_info
    # Contact Information
    config.add_show_field 'contact_information_ssi', label: 'Contact Information', itemprop: 'contact_information', type: :coll_info
    # Fiscal Sponsor
    config.add_show_field 'fiscal_sponsor_ssi', label: 'Fiscal Sponsor', itemprop: 'fiscal_sponsor', type: :coll_info

    ## Identifiers
    # DLS Identifier
    config.add_show_field 'local_identifier_ssi', label: 'DLS Identifier', itemprop: 'identifier', type: :identifiers

    ## Can I Use It?
    # Copyright Statement...
    config.add_show_field 'local_rights_tesi', label: 'Copyright Statement', itemprop: 'copyright', type: :use
    config.add_show_field 'sp_local_rights_tesi', label: 'Copyright Statement (Spanish)', itemprop: 'copyright_sp', type: :use

    config.add_show_field 'rights_uri_ssi', label: 'Rights Statement URI', itemprop: 'rights_uri', type: :use
    config.add_show_field 'sp_rights_uri_ssi', label: 'Rights Statement URI (Spanish)', itemprop: 'rights_uri_sp', type: :use

    # View Helpers
    config.add_show_tools_partial(:citation)
    config.add_show_tools_partial(:transcript, if: proc { |_context, _config, options|
                                                     options[:document].transcripts?
                                                   })

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
