class GettyController < ApplicationController
  def getty
    # parameters in . . .
    @x = params[:x]
    @field_name = params[:field_name]
    # set to service call
    # @term = GettyJsonService.new(@x[1]).att_name
    @term = GettyJsonService.new(@x[1]).att_name.nil? ? @x[0].titleize : GettyJsonService.new(@x[1]).att_name.titleize

    # render partial
    render partial: 'metadata_field_getty_term', locals: { x: @x, term: @term, field_name: @field_name }
  end
end