# frozen_string_literal: true

# Thumbnail
module Umedia
  module Thumbnail
    extend ActiveSupport::Concern
    included do
      helper_method :thumbnail if respond_to?(:helper_method)
    end

    def thumbnail(document, _options = {})
      if document.sidecar.image.attached?
        thumbnail = document.sidecar.image_url
      else
        Umedia::StoreImageJob.perform_later(document.id)
        thumbnail = document.cdm_thumbnail
      end

      view_context.render_thumbnail(thumbnail)
    end
  end
end
