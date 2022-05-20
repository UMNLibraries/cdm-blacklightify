# frozen_string_literal: true

module Umedia
  # Umedia::PurgeImageJob
  class PurgeImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id)
      document = SolrDocument.find(solr_document_id)
      Umedia::ImageService.new(document).purge!
    end
  end
end
