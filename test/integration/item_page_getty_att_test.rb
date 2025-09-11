require 'test_helper'

class ItemPageGettyAttTest < ActionDispatch::IntegrationTest

  test 'format field is array of two formats, each with a tooltip' do
    get root_path + '/catalog' + '/p16022coll215:0'
    assert_response :success

    assert_template partial: '_show'
    assert_template partial: '_show_fields'

    assert_select 'dd.getty-format-name' do
      assert_select 'div', text: /.+/, count: 2
    end

    assert_select 'dd.getty-format-name' do
      assert_select 'div', text: "?", count: 2
    end
  end

  test 'tooltip div has data-original-title' do
  end
end