# frozen_string_literal: true

require 'sidekiq'

class IndexCollectionWorker
  include Sidekiq::Worker

  # Sidekiq job to process a Umedia::Collection object
  def perform(collection_data)
    # Deserialize the collection data into a Umedia::Collection object
    collection = Umedia::Collection.new(
      id: collection_data['id'],
      name: collection_data['name']
    )

    # Call the IndexCollectionsService to index the collection
    service = IndexCollectionService.new([collection])
    service.index_all
  rescue StandardError => e
    # Log any errors that occur during processing
    logger.error "Failed to index collection: #{collection_data.inspect}, Error: #{e.message}"
    raise e
  end
end
