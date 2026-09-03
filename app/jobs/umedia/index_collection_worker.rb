# frozen_string_literal: true

require 'sidekiq'

module Umedia
  class IndexCollectionWorker
    include Sidekiq::Worker

    # Sidekiq job to process a Umedia::Collection object
    def perform(collection_json)

      logger.info "IndexCollectionWorker: Indexing collection: #{collection_json.inspect}"
      # Call the IndexCollectionsService to index the collection
      service = IndexCollectionService.new(Umedia::Collection.from_json(collection_json))
      service.index_all
    rescue StandardError => e
      # Log any errors that occur during processing
      logger.error "Failed to index collection: #{collection_json.inspect}, Error: #{e.message}"
      raise e
    end
  end
end
