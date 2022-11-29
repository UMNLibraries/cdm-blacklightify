# frozen_string_literal: true

require 'test_helper'

module Umedia
  class StoreImageJobTest < ActiveJob::TestCase
    test 'harvests an image' do
      assert_enqueued_jobs(1) do
        Umedia::StoreImageJob.new('p16022coll262:173').perform_now
      end
    end

    test 'perform can fetch a SolrDocument' do
      document = SolrDocument.find('p16022coll262:173')
      assert_equal('p16022coll262:173', document.id)
    end
  end
end
