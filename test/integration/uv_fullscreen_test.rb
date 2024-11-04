require 'test_helper'

class UvFullscreen < ActionDispatch::IntegrationTest
  test 'test fullscreen=true' do
    get root_path + '/catalog' + '/p16022coll208:5361' + '?fullscreen=true'
    assert_response :success
  end

  test 'test uv config fullscreenEnabled: false,' do
  end
end