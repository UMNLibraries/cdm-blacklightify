class IiifControllerTest < ActionDispatch::IntegrationTest
  test 'should get iiif#show/manifest.json' do
    get root_path + '/iiif/p16022coll282:166/manifest.json'
    assert_response :success
  end
end
