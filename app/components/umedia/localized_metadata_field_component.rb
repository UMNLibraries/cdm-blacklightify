# frozen_string_literal: true
#
module Umedia
  class LocalizedMetadataFieldComponent < Blacklight::MetadataFieldComponent
    def label(locale:)
      I18n.translate(@field.label, locale: (locale || I18n.default_locale))
    end

    def title_attribute(locale:)
      I18n.translate(@field.field_tooltips, locale: (locale || I18n.default_locale))
    end

    def tooltip_icon(locale:)
      title_attribute(locale: (locale || I18n.default_locale)).include? "Translation missing:"
    end
  end
end
