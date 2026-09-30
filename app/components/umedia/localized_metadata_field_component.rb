# frozen_string_literal: true
#
# LocalizedMetadataFieldComponent: Custom metadata field component for Spotlight compatibility.
# Handles label translation and configuration fallback when Spotlight config is incomplete.
module Umedia
  class LocalizedMetadataFieldComponent < Blacklight::MetadataFieldComponent
    # Override label() to handle literal labels (e.g., "Format") vs i18n keys (e.g., "item.fields.label").
    # Falls back to default Blacklight config when label is missing. Prevents translation errors in Spotlight.
    def label(locale:)
      label_key = @field.label

      # If label lacks a dot, it's a literal label (not an i18n key), so return as-is.
      if label_key.present? && !label_key.include?(".")
        return label_key
      end

      # SPOTLIGHT FALLBACK:
      # Fall back to default Blacklight config when label is missing (Spotlight compatibility).
      if label_key.blank?
        field_name = @field.field || @field.key
        default_config = CatalogController.blacklight_config
        if default_config && default_config.show_fields[field_name]
          label_key = default_config.show_fields[field_name][:label]
        end
      end

      # Translate the i18n key (or return literal label as-is).
      I18n.translate(label_key, locale: (locale || I18n.default_locale))
    end

    def title_attribute(locale:)
      I18n.translate(@field.field_tooltips, locale: (locale || I18n.default_locale))
    end

    def tooltip_icon(locale:)
      title_attribute(locale: (locale || I18n.default_locale)).include? "Translation missing:"
    end
  end
end
