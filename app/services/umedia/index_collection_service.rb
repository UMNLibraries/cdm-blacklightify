# frozen_string_literal: true

module Umedia
  class IndexCollectionService
    attr_reader :collection

    # Initialize the service with a Umedia::Collection object
    def initialize(collection)
      unless collection.is_a?(Umedia::Collection)
        raise ArgumentError, 'Expected a Umedia::Collection object'
      end

      @collection = collection
    end

    # Example method to index all collections
    def index_db
      exhibit = Spotlight::Exhibit.find_or_initialize_by(set_spec: collection.set_spec)
      exhibit.title = collection.name
      exhibit.description = collection.description
      exhibit.slug ||= collection.set_spec.parameterize
      exhibit.save!
    end

    def index_solr
      Blacklight.default_index.connection.add(collection.to_solr)
      Blacklight.default_index.connection.commit
    end

    def index_all
      index_db
      index_solr
    end
  end
end
