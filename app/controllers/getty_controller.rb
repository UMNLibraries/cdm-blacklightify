class GettyController < ApplicationController
  def getty
    @format_arr = params[:format_arr]
    @field_name = params[:field_name]
    # if getty att name is nil, use the name from cdm. could be cleaned up . . .
    @term = GettyJsonService.new(@format_arr[1]).att_name.nil? ? @format_arr[0].titleize : GettyJsonService.new(@format_arr[1]).att_name.titleize
   
    render partial: 'metadata_field_getty_term', locals: { format_arr: @format_arr, term: @term, field_name: @field_name }
  end
end