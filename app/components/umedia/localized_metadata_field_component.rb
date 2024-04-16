# frozen_string_literal: true
#
module Umedia
  class LocalizedMetadataFieldComponent < Blacklight::MetadataFieldComponent
    def label(locale:)
      I18n.translate(@field.label, locale: (locale || I18n.default_locale))
    end
  end
end
