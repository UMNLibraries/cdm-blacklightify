# frozen_string_literal: true

##
# Simplified catalog controller
class TranscriptController < ApplicationController
  include Blacklight::Catalog
  include Umedia::Thumbnail
  include Umedia::Localizable
  #after_action ->{ Rails.logger.debug(@response.documents.map{|doc| doc['transcription']}) }
  after_action ->{ Rails.logger.debug(@response.documents.map{|doc| doc['transcription']}.inspect) }

  configure_blacklight do |config|
    # special search builder
    config.search_builder_class = TranscriptSearchBuilder
    config.raw_endpoint.enabled = true

    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*',
      fq: 'record_type:secondary'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'title'
    config.add_index_field 'transcription', label: ''
    config.add_index_field 'parent_id', label: ''

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')
  end

  # get transcript results from the solr index
  def index
    super
    respond_to do |format|
      format.html do
        return render layout: false if request.xhr?
      end
    end
  end
end
