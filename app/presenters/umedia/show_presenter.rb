# frozen_string_literal: true

module Umedia
  # ShowPresenter customization for Spotlight compatibility.
  # Overrides configuration() to use CatalogController's default Blacklight config
  # instead of Spotlight's incomplete config, ensuring all metadata fields render
  # identically in both /catalog and /spotlight contexts.
  class ShowPresenter < Blacklight::ShowPresenter
    include Umedia::Localizable
    include Umedia::LocalizableFields

    # section heading level
    def config_type(locale = :en)
      h = {}
      CatalogController.field_types.each do |sect|
        h[sect] = I18n.t("item.field_sections.#{sect.to_s}", locale: locale)
        # h[sect] = I18n.t("item.field_tooltips.#{sect.to_s}", locale: locale)
      end
      h
    end

    def type_arr(type)    # returns boolean if any field in field_type_arr is present in the document
      field_type_arr =[]
      configuration.show_fields.to_a.each do |item|
        if item[1][:type] == type   # sets the field type
          field_type_arr.push(item[0])
        end
      end

      field_type_arr.each do |field|   # checks document for field presence
        return true if document[field].present?
      end
      return false
    end

    # Override to always use default Blacklight config for Spotlight exhibits.
    # Ensures Spotlight exhibits have access to all 54 metadata fields (not just
    # Spotlight's incomplete 10 fields) and use correct Solr field names.
    def configuration
      # Always use the CatalogController's Blacklight configuration for Spotlight exhibits
      # This ensures they have the same fields, field names, and field types as regular catalog
      CatalogController.blacklight_config
    end

    # Override to iterate fields in explicit order from UMEDIA_SHOW_FIELDS constant.
    # Ensures consistent field ordering across all contexts regardless of Hash merge order.
    def each_field(type)
      # Get defined field order from UMEDIA_SHOW_FIELDS constant
      defined_fields_for_type = CatalogController::UMEDIA_SHOW_FIELDS[type] || []

      # Collect all available fields from fields_to_render
      all_fields = {}
      fields_to_render do |field_name, field_config, field_presenter|
        all_fields[field_name] = [field_config, field_presenter]
      end

      # Iterate in explicit order to ensure consistent ordering across all contexts
      defined_fields_for_type.each do |field_name|
        next unless all_fields[field_name]

        field_config, field_presenter = all_fields[field_name]
        field_type = field_config[:type]
        yield field_name, field_config, field_presenter if field_type == type
      end
    end

    def html_title(locale = :en)
      @document[field_name_localized(:title, locale)]
    end

    # Replaces Blackligh::ShowPresenter#heading to use our field localization with the title field
    def localized_document_heading(locale = :en)
      html_title(locale)
    end

    def alternate_languages
      # English always an option
      langopts = {
        en: I18n.t('ui.change_lang_to', locale: :en)
      }
      (@document['alternate_languages'] || []).each do |locale|
        langopts[locale.to_sym] = I18n.t('ui.change_lang_to', locale: locale.to_sym)
      end
      langopts
    end
  end
end
