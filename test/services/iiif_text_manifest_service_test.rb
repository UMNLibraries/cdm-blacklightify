require 'test_helper'

class IiifTextManifestServiceTest < ActiveSupport::TestCase
  def setup
    @id = 'p16022coll208:0'
    @service = IiifTextManifestService.new(@id).call
  end

  test 'route has iiif manifest' do
    manifest = @service.to_json
  end

  test 'viewingHingt:paged' do
  end
end
