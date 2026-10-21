require 'test_helper'

class IiifAvManifestServiceTest < ActiveSupport::TestCase
  def setup
    @previous_partner_id = ENV['KALTURA_PARTNER_ID']
    @previous_single_uiconf = ENV['KALTURA_PLAYER_UICONF_ID_SINGLE']
    @previous_compound_uiconf = ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND']
    ENV['KALTURA_PARTNER_ID'] = '1369852'
    ENV['KALTURA_PLAYER_UICONF_ID_SINGLE'] = '12345'
    ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND'] = '67890'

    @id = 'p16022coll171:4951'
    @service = IiifAvManifestService.new(@id).av_manifest
  end

  def teardown
    ENV['KALTURA_PARTNER_ID'] = @previous_partner_id
    ENV['KALTURA_PLAYER_UICONF_ID_SINGLE'] = @previous_single_uiconf
    ENV['KALTURA_PLAYER_UICONF_ID_COMPOUND'] = @previous_compound_uiconf
  end

  test 'returns presentation 3 manifest' do
    assert_equal 'http://iiif.io/api/presentation/3/context.json', @service['@context']
    assert_equal 'Manifest', @service['type']
    assert @service['id'].present?
    assert @service['label']['en'].present?
    assert @service['requiredStatement']['value']['en'].present?
    assert @service['items'].any?
    refute @service.key?('sequences')
    refute @service.key?('@id')
    refute @service.key?('@type')
  end

  test 'creates canvases with painting annotations and targets' do
    canvas = @service['items'].first
    page = canvas['items'].first
    annotation = page['items'].first

    assert_equal 'Canvas', canvas['type']
    assert_equal 'AnnotationPage', page['type']
    assert_equal 'Annotation', annotation['type']
    assert_equal 'painting', annotation['motivation']
    assert_equal canvas['id'], annotation['target']
    assert annotation['body']['id'].present?
  end
end
