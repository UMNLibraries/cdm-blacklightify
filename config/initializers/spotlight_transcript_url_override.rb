# frozen_string_literal: true

module Spotlight
  module TranscriptUrlOverride
    private

    def url_for(options = {})
      # Handle transcript requests in Spotlight context
      return main_app.transcript_solr_document_url(id: options[:id]) if options.is_a?(Hash) && options[:controller] == 'spotlight/transcript' && options[:id].present?
      
      super
    rescue ActionController::UrlGenerationError => e
      # If URL generation fails for spotlight/transcript, redirect to main app
      if e.message.include?('spotlight/transcript')
        options = options.is_a?(Hash) ? options : {}
        id = options[:id]
        return main_app.transcript_solr_document_url(id: id) if id.present?
      end
      raise
    end
  end
end

# Monkeypatch Spotlight::CatalogController to use our URL override
Spotlight::CatalogController.prepend(Spotlight::TranscriptUrlOverride)
