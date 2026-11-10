# frozen_string_literal: true

module Blacklight
  class MetadataFieldComponent < Blacklight::Component
    with_collection_parameter :field

    # @param field [Blacklight::FieldPresenter]
    # @param layout [Blacklight::MetadataFieldLayoutComponent] alternate layout component to use
    # @param show [Boolean] are we showing only a single document (vs a list of search results); used for backwards-compatibility
    # @param view_type [String] optional view type for index field labels
    def initialize(field:, layout: nil, show: false, view_type: nil)
      @field = field
      @layout = layout || Blacklight::MetadataFieldLayoutComponent
      @show = show
      @view_type = view_type
    end

    def label
      if @show
        show_field_label @field.label('show')
      else
        index_field_label @field.label
      end
    end

    def index_field_label(label)
      html_escape t(:"blacklight.search.index.#{@view_type}.label", default: :'blacklight.search.index.label', label: label)
    end

    def show_field_label(label)
      t(:'blacklight.search.show.label', label: label)
    end

    def render?
      @field.render_field?
    end
  end
end
