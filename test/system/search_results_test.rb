# frozen_string_literal: true

require 'application_system_test_case'

class HomepageTest < ApplicationSystemTestCase
  test 'Search Results -  Dom' do
    visit '/spotlight/world-war-poster-collection/catalog?exhibit_id=world-war-poster-collection&search_field=all_fields&q=war'
    assert page.has_selector?('nav.navbar')
    assert page.has_selector?('main#main-container')
    assert page.has_selector?('form.search-query-form')
    assert page.has_selector?('div.constraints-container')
    assert page.has_selector?('div#facets')
    assert page.has_selector?('section#content')
    assert page.has_selector?('div#documents')
  end

  test 'Search Result - Result Dom' do
    visit '/spotlight/world-war-poster-collection/catalog?exhibit_id=world-war-poster-collection&search_field=all_fields&q="p16022coll208%3A200"'
    within('article') do
      assert page.has_selector?('header.documentHeader')
      assert page.has_selector?('h3.index_title')
      assert page.has_selector?('span.document-counter')
      assert page.has_selector?('div.document-thumbnail')
      assert page.has_selector?('dl.document-metadata')
    end
  end
end
