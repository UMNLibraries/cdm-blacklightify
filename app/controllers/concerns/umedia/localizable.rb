# frozen_string_literal: true

module Umedia
  module Localizable
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :current_locale
        helper_method :default_locale?
      end
    end

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
  end
end
