# frozen_string_literal: true

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :success
  end

  test 'should get catalog#show/raw' do
    get '/catalog/p16022coll282:4660/raw'
    assert_response :success
  end
end
