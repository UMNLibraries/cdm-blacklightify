# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller
  include Umedia::Localizable

  if respond_to?(:helper_method)
    # Expose these to layouts/partials that need query-aware Spotlight metadata.
    helper_method :current_locale, :set_spec_query_token, :spotlight_search_title, :spotlight_search_long_description
  end

  layout :determine_layout if respond_to? :layout
    # Permit language= param to be passed and check against defined I18n locales
    # Enables switching locale per page view with ease, for metadata records
    # that support alternate languages
    def current_locale
      lang = params.fetch(:language, I18n.default_locale).to_sym
      I18n.available_locales.include?(lang) ? lang : I18n.default_locale
    end

    # Extract set_spec:* from q so views can display the matched browse-category context.
    def set_spec_query_token
      query = params[:q].to_s
      query[/\bset_spec:[^\s]+\b/]
    end

    def spotlight_search_title
      spotlight_search_context&.[](:title)
    end

    def spotlight_search_long_description
      spotlight_search_context&.[](:long_description)
    end

    def spotlight_search_context
      return @spotlight_search_context if defined?(@spotlight_search_context)

      token = set_spec_query_token
      return @spotlight_search_context = nil if token.blank?

      # Keep lookup exhibit-scoped when the request is inside an exhibit.
      scope = Spotlight::Search
      scope = scope.where(exhibit_id: current_exhibit.id) if current_exhibit

      # query_params stores the saved browse query YAML/text (including set_spec:*).
      # We return one match with a non-empty long description as display context for the page.
      row = scope
        .where('query_params LIKE ?', "%#{token}%")
        .where.not(long_description: [nil, ''])
        .order(updated_at: :desc)
        .limit(1)
        .pick(:title, :long_description)

      @spotlight_search_context = row ? { title: row[0], long_description: row[1] } : nil
    end
end
