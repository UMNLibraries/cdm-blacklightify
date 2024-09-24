# frozen_string_literal: true

module Umedia
  module LocalizableFields
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :field_locale
        helper_method :field_name_unlocalized
        helper_method :localizable_field_names
        helper_method :localizable_field_name?
      end
    end

    # Item level fields which may be localized
    UMEDIA_LOCALIZED_SHOW_FIELDS = {
      default: [],
      primary: %w[ title description notes ],
      topic: %w[ subject language ],
      phys_desc: %w[ format format_name dimensions ],
      geo_loc: %w[ country continent ],
      coll_info: [],
      identifiers: [],
      use: %w[ local_rights rights_statement_uri ]
    }

    # Return a 1D list of localizable field names
    def localizable_field_names
      UMEDIA_LOCALIZED_SHOW_FIELDS.map{|k,v| v}.flatten.compact
    end

    def localizable_field_name?(field_name)
      localizable_field_names.include?(field_name_unlocalized(field_name))
    end

    def field_locale(field_name)
      prefix = field_name.split('_', 2).to_a.first.to_sym
      I18n.available_locales.include?(prefix) ? prefix : I18n.default_locale
    end

    def field_name_unlocalized(field_name)
      prefix, field_unprefixed = field_name.split('_', 2)
      # Prefix is a valid locale and the field is localizable, return it unprefixed
      # Otherwise return the full input field name
      I18n.available_locales.include?(prefix.to_sym) && localizable_field_names.include?(field_unprefixed) ? field_unprefixed : field_name
    end

    def field_name_localized(field_name, locale = I18n.default_locale)
      if locale == I18n.default_locale
        field_name.to_s
      else
        "#{locale.to_s}_#{field_name}"
      end
    end
  end
end
