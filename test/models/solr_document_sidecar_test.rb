# frozen_string_literal: true

require 'test_helper'

class SolrDocumentSidecarTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    # p16022coll208:1
    @sidecar = solr_document_sidecars(:the_fighting_scotsman)
  end

  test 'responds to instance methods' do
    assert_respond_to @sidecar, :document
    assert_respond_to @sidecar, :document_type
    assert_respond_to @sidecar, :image
    assert_respond_to @sidecar, :image_url
    assert_respond_to @sidecar, :reimage!
  end

  test 'image_url retrives local image' do
    assert_predicate(@sidecar.image, :attached?)
    assert_match(/p16022coll208-1.jpeg/, @sidecar.image_url)
  end

  test 'reimage creates a background queue job' do
    assert_enqueued_jobs(1) do
      @sidecar.reimage!
      assert_not(@sidecar.image.attached?)
    end
  end
end
