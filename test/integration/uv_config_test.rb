require 'test_helper'

class UvConfigTest < ActionDispatch::IntegrationTest
  test 'universal viewer configure option' do
    get root_path + '/catalog' + '/p16022coll282:166'
    assert_response :success
    assert_select 'div#doc_p16022coll282-166' do
      assert_select 'script', text: /pagingEnabled: false/
    end
  end
end