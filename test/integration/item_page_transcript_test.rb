require 'test_helper'

class ItemPageTranscriptTest < ActionDispatch::IntegrationTest
  test 'test transcript#index' do
    get root_path + '/catalog' + '/p16022coll613:15' + '/transcript'
    assert_response :success
    assert_select 'div.modal-body'
  end

  test 'transcript display' do
    get root_path + '/catalog' + '/p16022coll613:15'
    assert_response :success
    assert_template partial: '_transcript'
    assert_select 'div.modal-body' do
      assert_select 'div#transcript_hello'
    end
  end

  test 'transcript display if transcript_test' do
    get root_path + '/catalog' + '/p16022coll171:3716'
    assert_response :success
    assert_template partial: '_transcript'
    assert_select 'div.modal-body' do
      assert_select 'div.modal-header', text: /.+/, count: 1
    end
  end
end