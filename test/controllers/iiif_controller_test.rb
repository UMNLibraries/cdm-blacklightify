class IiifControllerTest < ActionDispatch::IntegrationTest
  def setup
    @previous_partner_id = ENV['KALTURA_PARTNER_ID']
    @previous_single_uiconf = ENV['KALTURA_PLAYER_UICONF_ID_SINGLE']
    @previous_compound_uiconf = ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND']
    ENV['KALTURA_PARTNER_ID'] = '1369852'
    ENV['KALTURA_PLAYER_UICONF_ID_SINGLE'] = '12345'
    ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND'] = '67890'
  end

  def teardown
    ENV['KALTURA_PARTNER_ID'] = @previous_partner_id
    ENV['KALTURA_PLAYER_UICONF_ID_SINGLE'] = @previous_single_uiconf
    ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND'] = @previous_compound_uiconf
  end

  test 'should route iiif text manifest endpoint' do
    assert_recognizes(
      { controller: 'iiif', action: 'text_manifest', id: 'p16022coll208:401', manifest: 'manifest', format: 'json' },
      '/iiif/p16022coll208:401/text/manifest.json'
    )
  end

  test 'should get iiif av manifest endpoint' do
    get root_path + '/iiif/p16022coll262:500/av/manifest.json'
    assert_response :success
  end
end
