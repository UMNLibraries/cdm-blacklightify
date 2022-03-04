# frozen_string_literal: true

require 'application_system_test_case'

class HomepageTest < ApplicationSystemTestCase
  test 'homepage dom' do
    visit root_url
    assert page.has_selector?('nav.navbar')
    assert page.has_selector?('main#main-container')
    assert page.has_selector?('div.jumbotron')
    assert page.has_selector?('div#getting-started')
    assert page.has_selector?('div#about')
  end
end
