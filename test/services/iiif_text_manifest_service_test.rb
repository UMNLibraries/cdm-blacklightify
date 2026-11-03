require 'test_helper'

class IiifTextManifestServiceTest < ActiveSupport::TestCase
  def setup
    @id = 'p16022coll208:0'
    @service_object = IiifTextManifestService.new(@id)
    @service_object.singleton_class.define_method(:cdm_manifest) do
      {
        'sequences' => [{
          'canvases' => [{
            '@id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/canvas/c0",
            'label' => 'Canvas 1',
            'width' => 4000,
            'height' => 3000,
            'images' => [{
              'resource' => {
                '@id' => "https://cdm16022.contentdm.oclc.org/iiif/2/#{@id}/full/full/0/default.jpg",
                'format' => 'image/jpeg',
                'width' => 4000,
                'height' => 3000,
                'service' => {
                  '@id' => "https://cdm16022.contentdm.oclc.org/iiif/2/#{@id}",
                  'profile' => 'http://iiif.io/api/image/2/level1.json'
                }
              }
            }]
          }]
        }],
        'structures' => [{
          'canvases' => ["https://cdm16022.contentdm.oclc.org/iiif/#{@id}/canvas/c0"]
        }]
      }
    end
    @service = @service_object.call
  end

  test 'returns presentation 3 manifest' do
    assert_equal 'http://iiif.io/api/presentation/3/context.json', @service['@context']
    assert_equal 'Manifest', @service['type']
    assert @service['id'].present?
    assert_equal ['paged'], @service['behavior']
    assert @service['label']['en'].present?
    assert @service['items'].any?
    refute @service.key?('sequences')
    refute @service.key?('@id')
    refute @service.key?('@type')
  end

  test 'creates canvas, range, and search service using v3 structure' do
    canvas = @service['items'].first
    range = @service['structures'].first
    search_service = @service['service'].first

    assert_equal 'Canvas', canvas['type']
    assert_equal canvas['id'], canvas.dig('items', 0, 'items', 0, 'target')
    assert_equal 'Range', range['type']
    assert_equal 'Canvas', range.dig('items', 0, 'type')
    assert_equal 'SearchService1', search_service['type']
    assert_equal 'AutoCompleteService1', search_service.dig('service', 0, 'type')
  end
end
