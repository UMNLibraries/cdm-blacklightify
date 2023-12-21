require 'test_helper'

class ItemPageSectionHeadingTest < ActionDispatch::IntegrationTest
  test 'section headings display' do
    get root_path + '/catalog' + '/p16022coll208:11'
    assert_response :success
    assert_template partial: '_show'
    assert_template partial: '_show_fields'
    assert_select 'div#item-details' do 
      assert_select 'h3', text: /.+/, count: 4
    end
  end
end