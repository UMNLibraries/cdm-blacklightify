class GettyJsonController < ApplicationController
  def format_json
    response = GettyJsonService.new(params[:id]).aat_data
    render json: response
  end
end