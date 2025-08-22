class GettyJsonController < ApplicationController
  # def format_json
  #   res = GettyJsonService.new().data
  #   parsed_response = res.body
  #   JSON.parse(parsed_response)
  # end

  def format_json
    response = GettyJsonService.new(params[:id]).data
    render json: response
  end
end