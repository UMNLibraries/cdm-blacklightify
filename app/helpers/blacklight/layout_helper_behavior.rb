# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the hosting
# application
module Blacklight
  # A module for useful methods used in layout configuration
  module LayoutHelperBehavior
    ##
    # Classes added to a document's show content div
    # @return [String]
    def show_content_classes
      "#{main_content_classes} show-document"
    end

    ##
    # Attributes to add to the <html> tag (e.g. lang and dir)
    # @return [Hash]
    def html_tag_attributes
      { lang: current_locale }
    end

    ##
    # Classes added to a document's sidebar div
    # @return [String]
    def show_sidebar_classes
      sidebar_classes
    end

    ##
    # Classes used for sizing the main content of a Blacklight page
    # @return [String]
    def main_content_classes
      'col'
    end

    ##
    # Classes used for sizing the sidebar content of a Blacklight page
    # @return [String]
    def sidebar_classes
      'page-sidebar col-lg-3'
    end

    ##
    # Class used for specifying main layout container classes. Can be
    # overwritten to return 'container-fluid' for Bootstrap full-width layout
    # @return [String]
    def container_classes
      'container-fluid'
    end

    def transcript_selector
      # determines where to get transcript data from (if [:transcription_tesi].present?)
      # [2026-04-01] currently this has been replaced with an array inclusion method in the erb template and may be unnecessary . . .
      @document[:viewer_type] == 'image'
    end

    def tools_iiif_manifest_link
      arr = ['Sound', 'Moving Image']
      @document[:types].present? ? arr.include?(@document[:types][0]) : ""
    end

    def fullscreen?
      params[:fullscreen] == 'true'
    end
  end
end
