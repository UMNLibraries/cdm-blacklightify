# frozen_string_literal: true

##
# ThumbnailHelper
module ThumbnailHelper
  def render_thumbnail(thumbnail = placeholder, alt_text: "Item thumbnail")
    image_tag(thumbnail, alt: alt_text)
  end

  def placeholder
    image_url('placeholder.png')
  end
end
