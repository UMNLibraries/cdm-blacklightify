# frozen_string_literal: true

module Umedia
  # Umedia::StoreImageJob
  class StoreImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id)
      document = SolrDocument.find(solr_document_id)
      Umedia::ImageService.new(document).store!
    end
  end
end
