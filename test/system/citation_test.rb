# frozen_string_literal: true

require 'application_system_test_case'

class CitationTest < ApplicationSystemTestCase
  def setup; end

  def teardown
    # ran_without_js_errors
  end

  def test_citation_tool
    visit '/catalog/p16022coll262:173/citation'

    # Available from link should include slug
    assert page.has_content?('p16022coll262:173')

    # MLA Text
    assert page.has_content?('Institute for Advanced Study. The Haverford Group of Black Integrationists: Michael Lackey, Feb. 2014. 2014-02-13. University of Minnesota, Institute for Advanced Study., umedia.lib.umn.edu/item/p16022coll262:173')

    # Chicago Text
    assert page.has_content?('Institute for Advanced Study. 2014-02-13."The Haverford Group of Black Integrationists: Michael Lackey, Feb. 2014." University of Minnesota, Institute for Advanced Study.,')

    # Wikipedia
    assert page.has_content?('<ref name="University of Minnesota"> {{cite web | url=http://umedia.lib.umn.edu/item/p16022coll262:173 | | title= (Moving Image) The Haverford Group of Black Integrationists: Michael Lackey, Feb. 2014,(["2014-02-13"]) | ')
  end
end
