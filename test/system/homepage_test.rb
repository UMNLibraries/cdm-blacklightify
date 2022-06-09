# frozen_string_literal: true

require 'application_system_test_case'

class HomepageTest < ApplicationSystemTestCase
  def setup; end

  test 'Homepage Dom' do
    visit '/'
    assert page.has_selector?('nav.navbar')
    assert page.has_selector?('main#main-container')
  end

  test 'Homepage Facets' do
    skip('No longer showing facets on homepage')
    visit '/'
    within('#facets') do
      assert page.has_content?('Contributing Organization')
      assert page.has_content?('Collection')
      assert page.has_content?('Type')
      assert page.has_content?('Format')
      assert page.has_content?('Created')
      assert page.has_content?('Subject')
      assert page.has_content?('Publisher')
      assert page.has_content?('Contributor')
      assert page.has_content?('Language')
    end
  end

  test 'Search Form' do
    visit '/'
    within('div.navbar-search') do
      fill_in('q', with: 'water')
      click_button 'Search'
    end

    assert page.has_content?('Search Results')
  end
end
