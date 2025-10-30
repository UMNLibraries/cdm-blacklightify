class SubjectController < ApplicationController
  include Blacklight::Controller
  include Spotlight::Controller
  include Umedia::Localizable

  def subject
    @url = params[:url]

    render partial: 'metadata_field_component_sf_two', locals: { url: @url }
  end
end