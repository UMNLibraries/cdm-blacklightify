require 'test_helper'

class UvFullscreen < ActionDispatch::IntegrationTest
  test 'test ?fullscreen=true' do
    get root_path + '/catalog' + '/p16022coll208:5361' + '?fullscreen=true'
    assert_response :success
  end

  test 'test link_to solr_path' do
    get root_path + '/catalog' + '/p16022coll208:5361'
    assert_response :success
    assert_select 'a[href=?]', '/catalog/p16022coll208:5361?fullscreen=true'
  end

  test 'fullscreen width & height 100vh' do
    get root_path + '/catalog' + '/p16022coll208:5361' + '?fullscreen=true'
    assert_response :success
    assert_select 'div#uv[style="width: 99.25vw; height: 100vh;"]'
  end

  test 'back to item page' do
    get root_path + '/catalog' + '/p16022coll208:5361' + '?fullscreen=true'
    assert_response :success
    assert_select 'div.d-flex' do
      assert_select 'a'
    end
  end
end