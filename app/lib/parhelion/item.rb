# frozen_string_literal: true

module Parhelion
  # Converts a result hash into an Item object with Field Object children
  class Item
    attr_reader :doc_hash, :field_klass, :cdn_iiif_klass, :cdn_webservices_klass
    def initialize(doc_hash: {},
                   field_klass: Field,
                   cdn_iiif_klass: IiifConfig,
                   cdn_webservices_klass: CdmapiImageInfo)
      # doc_hash is a document returned from a Solr search as a hash
      @doc_hash     = doc_hash
      @field_klass  = field_klass
      @cdn_iiif_klass = cdn_iiif_klass
      @cdn_webservices_klass = cdn_webservices_klass
    end

    def url
      "#{ENV['RAILS_BASE_URL']}/item/#{index_id}"
    end

    def iiif_url
      @iiif_source.iiif_url
    end

    def height
      iiif_info.fetch('height', 0)
    end

    def width
      iiif_info.fetch('width', 0)
    end

    # Retrieve original uploaded image dimensions from CONTENTdm
    # Unconstrained by IIIF max image size
    def cdn_webservices_url
      webservices_source.info_url
    end

    def original_height
      webservices_image_info.fetch('height', 0)
    end

    def original_width
      webservices_image_info.fetch('width', 0)
    end

    def type
      doc_hash.fetch('types', []).first
    end

    # Solr index identifier, also used in item path
    # items/coll123:999 <-- path id
    def index_id
      doc_hash.fetch('id')
    end

    def id
      doc_ids.last
    end

    # If an item doesn't have a parent ID field,
    # it is its own parent
    def parent_id
      parent_ids.last
    end

    def collection
      doc_ids.first
    end

    def viewer_type
      doc_hash['viewer_type']
    end

    def is_compound?
      viewer_type == 'COMPOUND_PARENT_NO_VIEWER'
    end

    def ==(other)
      doc_hash == other.doc_hash
    end

    def to_h
      doc_hash.merge(
        'type' => type,
        'collection' => collection,
        'is_compound' => is_compound?,
        'parent_id' => parent_id
      )
    end

    private

    # Retrieve info from IIIF
    def iiif_source
      @iiif_source ||= cdn_iiif_klass.new(id: id, collection: collection)
    end
    def iiif_info
      if !is_compound?
        @iiif_info ||= iiif_source.info
      else
        {}
      end
    end

    # Retrieve image info from CONTENTdm API
    def webservices_source
      @webservices_source ||= cdn_webservices_klass.new(id: id, collection: collection)
    end
    def webservices_image_info
      if !is_compound?
        @webservices_image_info ||= webservices_source.info
      else
        {}
      end
    end

    def doc_ids
      index_id.split(':')
    end

    def parent_ids
      doc_hash.fetch('parent_id', index_id).split(':')
    end

    def method_missing(method_name, *arguments, &block)
      if method_name.to_s =~ /field_(.*)/
        field($1, field_value($1))
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?('field_') || super
    end

    def field(name, value)
      field = doc_hash.key?(name) ? field_klass : MissingField
      field.new name: name, value: value
    end

    def field_value(field)
      doc_hash.fetch(field, false)
    end
  end
end
