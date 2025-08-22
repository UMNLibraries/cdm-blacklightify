# frozen_string_literal: true

# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride

  include Umedia::Thumbnail
  include Umedia::LocalizableFields
  include Umedia::Catalog::JsonBehaviors

  before_action :permit_language

  # All item level show fields grouped by type
  UMEDIA_SHOW_FIELDS = {
    default: %w[],
    # default: %w[ object ],
    primary: %w[title title_alternative description date_created creator contributor_ssim publisher_s historical_era caption
                notes],
    topic: %w[subject_ssm subject_fast_ssim language],
    phys_desc: %w[types format format_name dimensions],
    geo_loc: %w[city_ssim state_ssim country_ssim region_ssim continent_ssim projection scale coordinates geonames],
    coll_info: %w[collection_name_s parent_collection_name contributing_organization_name_s contact_information fiscal_sponsor],
    identifiers: %w[local_identifier barcode system_identifier dls_identifier persistent_url],
    use: %w[local_rights rights_statement_uri additional_rights_information standardized_rights
            expected_public_domain_year]
  }

  UMEDIA_LINK_TO_FACET_FIELDS = %w[
    creator
    contributor_ssim
    publisher_s
    subject_ssm
    subject_fast_ssim
    language
    types
    format
    format_name
    city_ssim
    state_ssim
    country_ssim
    region_ssim
    continent_ssim
    collection_name_s
    contributing_organization_name_s
  ]

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
      fq: 'record_type:primary',
      hl: true,
      'hl.method': 'original',
      'hl.fl': 'collection_* format_* subject title ',
      'hl.preserveMulti': true,
      'hl.simple.pre': '<span style=\'background-color: #ffde7a\'>',
      'hl.simple.post': '</span>'
    }

    config.document_solr_path = 'select'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'title'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

    # additional targeted search query field.
    config.add_search_field 'types', label: 'Type'
    config.add_search_field 'date_created', label: 'Date'
    config.add_search_field('subject') do |field|
      field.query_parameters = { 'spellcheck.dictionary': 'subject' }
      field.query_local_parameters = {
        qf: 'subject_ssm'
      }
    end

    # Show Presenter Class ("registers" the show_presenter file/class)
    config.show.document_presenter_class = Umedia::ShowPresenter

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')
    config.add_sort_field 'date_created_sort desc, title_sort asc', label: 'Year (Newest first)'
    config.add_sort_field 'date_created_sort asc, title_sort asc', label: 'Year (Oldest first)'
    config.add_sort_field 'title_sort asc', label: 'Title (A-Z)'
    config.add_sort_field 'title_sort desc', label: 'Title (Z-A)'
    config.add_sort_field 'creator_sort asc', label: 'Creator (A-Z)'
    config.add_sort_field 'creator_sort desc', label: 'Creator (Z-A)'

    # SERP / RESULTS PAGE
    # Format / format_name
    config.add_facet_field 'format_name', label: 'Format', limit: 4, collapse: false
    # Subject / subject
    config.add_facet_field 'subject_ssm', label: 'Subject', limit: 4, collapse: false
    config.add_facet_field 'subject_fast_ssim', label: 'FAST Subject Headings', limit: 4, collapse: false

    # Created / date_created
    config.add_facet_field 'date_created', label: 'Date created', limit: 4, collapse: false
    # Collection / collection_name
    config.add_facet_field 'collection_name_s', label: 'Collections', limit: 4, collapse: true
    # Language / language
    # config.add_facet_field 'language', label: 'Language', limit: 4, collapse: true
    # Creator / creator
    config.add_facet_field 'creator_s', label: 'Creator', limit: 4, collapse: true
    # Contributing Organization / contributing_organization
    config.add_facet_field 'contributing_organization_name_s', label: 'Contributing Organization', limit: 4,
                                                               collapse: true
    # Type / types
    config.add_facet_field 'types', label: 'Type', limit: 4, collapse: true
    # Special projects
    config.add_facet_field 'super_collection_name_ss', label: 'Special Projects', limit: 4, collapse: true
    # Publisher / publisher
    config.add_facet_field 'publisher_s', label: 'Publisher', limit: 4, collapse: true
    # Contributor / contributor
    config.add_facet_field 'contributor_ssim', label: 'Contributor', limit: 4, collapse: true
    # Geographic Fields
    # config.add_facet_field 'city', show: false
    config.add_facet_field 'city_ssim', label: 'City', collapse: true
    config.add_facet_field 'state_ssim', label: 'State', collapse: true
    config.add_facet_field 'country_ssim', label: 'Country', collapse: true
    config.add_facet_field 'region_ssim', label: 'Region', collapse: true
    config.add_facet_field 'continent_ssim', label: 'Continent', collapse: true

    # SEARCH RESULTS FIELDS
    config.add_index_field 'title', label: 'Title', highlight: true
    # Collection / collection_name
    config.add_index_field 'collection_name', label: 'Collection', highlight: true
    # Created
    config.add_index_field 'date_created', label: 'Date'
    # Format / format_name
    config.add_index_field 'format_name', label: 'Format', highlight: true
    # Subject / subject
    config.add_index_field 'subject_ssm', label: 'Subjects', link_to_facet: true, highlight: true,
                                      separator_options: { two_words_connector: '; ', words_connector: '; ', last_word_connector: '; ' }
    config.add_index_field 'subject_fast_ssim', label: 'FAST Subject Headingsgi', link_to_facet: true, highlight: true,
                                      separator_options: { two_words_connector: '; ', words_connector: '; ', last_word_connector: '; ' }
    # Thumbnails - A helper method that looks for attached image from solr_document_sidecar
    config.index.thumbnail_method = :thumbnail

    # ITEM PAGE VIEW FIELDS
    # Build out all item level show fields
    UMEDIA_SHOW_FIELDS.each do |type, fieldlist|
      fieldlist.each do |field|
        # Label as the config/locales translation label
        config.add_show_field(
          field,
          label: "item.fields.#{field}",
          field_tooltips: "item.field_tooltips.#{field}",
          itemprop: field,
          type: type,
          component: Umedia::LocalizedMetadataFieldComponent,
          link_to_facet: UMEDIA_LINK_TO_FACET_FIELDS.include?(field),
          separator_options: { two_words_connector: '; ', words_connector: '; ', last_word_connector: '; ' }
        )
        # If this metadata field is available to alt languages, add them now
        next unless UMEDIA_LOCALIZED_SHOW_FIELDS[type].include?(field)

        I18n.available_locales.reject { |l| l == I18n.default_locale }.each do |locale|
          config.add_show_field(
            "#{locale}_#{field}",
            label: "item.fields.#{field}",
            field_tooltips: "item.field_tooltips.#{field}",
            itempro: field,
            type: type,
            component: Umedia::LocalizedMetadataFieldComponent,
            # Never facet the alt lang metadata field
            link_to_facet: false
          )
        end
      end
    end

    # View Helpers
    config.add_show_tools_partial(:citation)
    # config.add_show_tools_partial(:transcript, if: proc { |_context, _config, options|
    #                                                  options[:document].transcripts?
    #                                                })

    # config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!
    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end

  # Returns an array of field types as symbols
  def self.field_types
    UMEDIA_SHOW_FIELDS.keys
  end

  def bad_request_no_search
    head :bad_request
  end

  # Allow the language parameter in controller actions
  def permit_language
    params.permit(:language)
  end
end
