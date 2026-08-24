# frozen_string_literal: true

module Umedia
  # A UMedia Collection is a set of items that are grouped together for some reason.
  class Collection
    attr_reader :set_spec, :name, :description, :super_collection_set_spec, :super_collection_name

    def initialize(
        set_spec:,
        name: '',
        description: '',
        super_collection_set_spec: nil,
        super_collection_name: nil
      )
      raise ArgumentError, 'set_spec is required' if set_spec.nil? || set_spec.empty?

      @set_spec = set_spec
      @name = name
      @description = description
      @super_collection_set_spec = super_collection_set_spec
      @super_collection_name = super_collection_name

    end

    def self.from_json(json)
      data = JSON.parse(json)
      new(
        set_spec: data['set_spec'],
        name: data['collection_name'],
        description: data['collection_description'],
        super_collection_set_spec: data['super_collection_set_spec'],
        super_collection_name: data['super_collection_name']
      )
    end

    # Since our CDM instance has both Reflections and UMedia content in it and
    # we can't choose setSpec names, we have a collection naming convention that
    # helps us identify which collections are reflections and which are umedia.
    # We chop this information off for public display
    def display_name
      self.class.display_name(name)
    end

    def super_collection_display_name
      self.class.display_name(super_collection_name)
    end

    def self.display_name(raw_name)
      raw_name&.gsub(/^ul_([a-zA-Z0-9])*\s-\s/, '')
    end

    def to_solr
      {
        id: "collection-#{set_spec}",
        document_type: 'collection',
        set_spec: set_spec,
        collection_name: display_name,
        collection_description: description,
        super_collection_set_spec: super_collection_set_spec,
        super_collection_names: super_collection_name
      }
    end

    def to_h
      to_solr
    end

    def to_json
      to_solr.to_json
    end
  end
end
