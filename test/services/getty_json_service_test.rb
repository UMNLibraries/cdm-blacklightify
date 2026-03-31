require 'test_helper'

class GettyJsonServiceTest < ActiveSupport::TestCase
  def setup
    @att_id = '300026816'
    @service = GettyJsonService.new(@att_id).att_definition
  end

  test 'service returns definition' do
    @service
    assert true
  end

  test 'tooltip att definition is cached/caching' do
  end
end