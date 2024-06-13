module Umedia
  module LocalizableHelper
    include Blacklight::BlacklightHelperBehavior

    def render_localized_document_heading
      content_tag(:h1, document_presenter(@document).localized_document_heading(current_locale), itemprop: 'name')
    end

    def locale_choices
      locale_choices = []
      document_presenter(@document).alternate_languages.each do |loc, translation|
        # Build a list of available metadata locales available to switch to
        # and omit whatever the existing view locale is
        locale_choices << link_to(translation, language: loc ) unless loc == current_locale
      end
      locale_choices
    end
  end
end
