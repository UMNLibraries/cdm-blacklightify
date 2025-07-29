require 'test_helper'

class UvConfigTest < ActionDispatch::IntegrationTest
  test 'universal viewer configure options' do
    get root_path + '/catalog' + '/p16022coll613:1441'
    assert_response :success

    # uv config
    # assert_select 'div#doc_p16022coll282-166' do
    #   assert_select 'script', text: /pagingEnabled: false/
    #   assert_select 'script', text: /rightPanelEnabled: true/
    #   assert_select 'script', text: /fullscreenEnabled: false/
    #   assert_select 'script', text: /imageSelectionBoxEnabled: true/
    # end
  end

  test 'fullScreen display: none' do
  end
  test 'uv single image object download links' do
  end
  test 'uv compound object download links' do
  end
end
