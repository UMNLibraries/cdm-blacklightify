# frozen_string_literal: true

module Umedia
  module Localizable
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :current_locale
        helper_method :default_locale?
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
      phys_desc: %w[ format format_name dimensions ],
      geo_loc: %w[ country continent ],
      topic: %w[ subject language ],
      coll_info: [],
      identifiers: [],
      use: %w[ local_rights rights_statement_uri ]
    }

    # Permit language= param to be passed and check against defined I18n locales
    # Enables switching locale per page view with ease, for metadata records
    # that support alternate languages
    def current_locale
      lang = params.fetch(:language, I18n.default_locale).to_sym
      I18n.available_locales.include?(lang) ? lang : I18n.default_locale
    end

    def default_locale?
      current_locale == I18n.default_locale
    end

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
  end
end
