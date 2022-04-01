# frozen_string_literal: true

require 'test_helper'

class SolrDocumentTest < ActiveSupport::TestCase
  def setup
    @document = SolrDocument.find('p16022coll262:173')
  end

  test 'responds to instance methods' do
    assert_respond_to @document, :more_like_this
    assert_respond_to @document, :cdm_thumbnail
  end

  test 'more_like_this contains array' do
    assert_kind_of Array, @document.more_like_this
  end

  test 'cdm_thumbnail link' do
    assert_equal 'https://cdm16022.contentdm.oclc.org/digital/api/singleitem/collection/p16022coll262/id/173/thumbnail', @document.cdm_thumbnail
  end
end
