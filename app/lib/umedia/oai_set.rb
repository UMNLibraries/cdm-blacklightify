# frozen_string_literal: true

module Umedia
  # All it does is convert an OAI set result to a UMedia Collection
  class OaiSet
    attr_reader :set, :collection_klass
    def initialize(set: :MISSING_SET,
                   collection_klass: Umedia::Collection)
      @set = set
      @collection_klass = collection_klass
    end

    def to_collection
      collection_klass.new(
        set_spec: set_spec,
        name: name,
        description: description
      )
    end

    private

    def set_spec
      set.fetch('setSpec', nil) or raise ArgumentError, 'Required setSpec not found, cannot create collection'
    end

    def name
      set.fetch('setName', nil)
    end

    def description
      set.fetch('setDescription', {}).fetch('dc', {}).fetch('description', nil)
    end
  end
end
