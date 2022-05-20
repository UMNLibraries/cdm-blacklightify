# frozen_string_literal: true

##
# ThumbnailHelper
module ThumbnailHelper
  def render_thumbnail(thumbnail=placeholder)
    image_tag(thumbnail)
  end

  def placeholder
    image_url('placeholder.png')
  end
end
