require "test_helper"

class ItemPageSectionHeadingTest < ActionDispatch::IntegrationTest

  def setup  
  end 

  test "section heading links" do
    get root_path + '/catalog' + '/p16022coll208:11'
    assert_response :success
    assert_template partial: '_show'
    assert_template partial: '_show_fields'
    assert_select 'h3', html: 'Physical Description'
    assert_select 'dt', html: 'Type:'
  end
end