# frozen_string_literal: true

require 'test_helper'

# Validate robots.txt generation
class RobotsControllerTest < ActionDispatch::IntegrationTest
  test 'should return a robots file' do
    get '/robots.txt'
    assert_response :success
  end
end
