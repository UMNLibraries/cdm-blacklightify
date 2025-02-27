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

    def transcript_tab
      # if "types" in array, do not display transcript tab . . .
      # should update this to just display based on presence of 'transcription' field presence instead of being based on item type . . .
      arr = ['Still Image', 'Sound', 'Moving Image']

      arr.include?(@document[:types][0])
    end

    def attachment_tab
      # if attachment type is in array, do not display tab; however, not all jp2 types fall intot this catalogr (holocaust oral history collection)
      # arr = ['url', 'jp2', 'cpd']
      arr = ['url', 'cpd']
      @document[:attachment] != nil && arr.include?(@document[:attachment].split(".")[1])
    end

    def tools_iiif_manifest_link
      arr = ['Sound', 'Moving Image']
      arr.include?(@document[:types][0])
    end

    def fullscreen?
      params[:fullscreen] == 'true'
    end
  end
end
