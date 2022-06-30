# frozen_string_literal: true

require 'application_system_test_case'

class TranscriptTest < ApplicationSystemTestCase
  def setup; end

  def teardown
    # ran_without_js_errors
  end

  def test_transcript_link
    # Text Fixture (Has transcript)
    visit '/catalog/p16022coll282:4660'

    # Link
    assert page.has_link?('Transcript')

    # Still Image Fixture (No transcript)
    visit '/catalog/p16022coll208:11'

    # No Link
    assert page.has_no_link?('Transcript')
  end

  def test_transcript_tool
    visit '/catalog/p16022coll282:4660/transcript'

    # Heading
    assert page.has_content?('Transcript')

    # Page Title
    assert page.has_content?('Page 2')

    # Page Text
    assert page.has_content?('Purchased by the McKnight-Binger Rare Book Fund Owen H. Wangensteen Historical Library of Biology and Medicine')
  end
end
