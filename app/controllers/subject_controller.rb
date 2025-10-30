class SubjectController < ApplicationController
  def subject
    @url = params[:url]
    @term = OclcSubjectFastService.new(@url).fast_data

    render partial: 'metadata_field_component_sf_two', locals: { url: @url, term: @term }
  end
end