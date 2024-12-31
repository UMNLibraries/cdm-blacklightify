require 'test_helper'

class IiifAvManifestServiceTest < ActiveSupport::TestCase
  def setup
    @id = 'p16022coll171:4951'
    @service = IiifAvManifestService.new(@id).av_manifest
  end

  test 'route has iiif manifest' do
    manifest = @service.to_json
  end
end
