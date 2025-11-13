class SubjectController < ApplicationController
  def subject
    @url = params[:url]
    # @term = OclcSubjectFastService.new(@url).fast_data
    @term = OclcSubjectFastService.new(@url).uri_check ? OclcSubjectFastService.new(@url).fast_data : @url

    render partial: 'metadata_field_component_sf_term', locals: { url: @url, term: @term }
  end
end