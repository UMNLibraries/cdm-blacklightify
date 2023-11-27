require 'test_helper'

class IiifViewingHintTest < ActiveSupport::TestCase
  def setup
    @id = 'p16022coll282:668'
    @service = IiifViewingHintService.new(@id).call
  end

  test 'iiif manifest has viewingHint appended' do
    manifest = @service.to_json
    assert_equal manifest['viewingHint'],'viewingHint'
  end
end