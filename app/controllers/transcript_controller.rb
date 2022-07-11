# frozen_string_literal: true

##
# Simplified catalog controller
class TranscriptController < ApplicationController
  include Blacklight::Catalog
  include Thumbnail

  configure_blacklight do |config|
    # special search builder
    config.search_builder_class = TranscriptSearchBuilder
    config.raw_endpoint.enabled = true

    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*',
      fq: 'record_type_ssi:secondary'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tesi'
    config.add_index_field 'transcription_tesi', label: ''
    config.add_index_field 'parent_id_ssi', label: ''

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
