# frozen_string_literal: true

module ApplicationHelper
  include SpotlightHelper

  def thumbnail(*args)
    document = args[0]

    if document.is_a?(SolrDocument)
      image_tag(document.cdm_thumbnail)
    else
      image_tag('placeholder.png')
    end
  end
end
