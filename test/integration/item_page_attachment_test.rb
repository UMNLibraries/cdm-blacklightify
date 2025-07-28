require 'test_helper'

class ItemPageAttachmentTest < ActionDispatch::IntegrationTest
  test 'test transcript#index' do
    get root_path + '/catalog' + '/p16022coll613:15' + '/transcript'

    assert_response :success
    assert_select 'div.modal-body'
  end

  test 'transcript display' do
    get root_path + '/catalog' + '/p16022coll613:15'

    assert_response :success
    assert_template partial: '_transcript'
    assert_select 'ul.nav' do
       assert_select 'li', 2
    end
    assert_select 'div.tab-content' do
      assert_select 'div#transcript_content'
    end
  end

  # this test may need to be updated. dependant on desired behavior for an a/v object
  # test 'transcript display if transcript_tesi' do
  #   get root_path + '/catalog' + '/p16022coll171:3716'

  #   assert_response :success
  #   assert_template partial: '_transcript'
  #   assert_select 'div.modal-body' do
  #     assert_select 'div.modal-header', text: /.+/, count: 1
  #   end
  # end

  test 'transcript tab !display (transcript_tab helper)' do
    get root_path + '/catalog' + '/p16022coll208:5292'

    assert_response :success
    assert_select 'ul.nav' do
      assert_select 'li', 1
    end
  end

  test 'attachment tab display a/v item with image attachment' do
    get root_path + '/catalog' + '/p16022coll215:4'
  
  end

  test 'attachment tab display a/v item with pdf attachment' do
    get root_path + '/catalog' + '/p16022coll171:3699'

    # assert on loading spinner . . .

  end
end
