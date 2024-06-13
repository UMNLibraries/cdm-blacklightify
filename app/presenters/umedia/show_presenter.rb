# frozen_string_literal: true

module Umedia
  class ShowPresenter < Blacklight::ShowPresenter
    include Umedia::Localizable
    include Umedia::LocalizableFields

    def config_type(locale = :en)
      h = {}
      CatalogController.field_types.each do |sect|
        h[sect] = I18n.t("item.field_sections.#{sect.to_s}", locale: locale)
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

    def each_field(type)
      fields_to_render do |field_name, field_config, field_presenter|
        yield field_name, field_config, field_presenter if field_config[:type] == type
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
