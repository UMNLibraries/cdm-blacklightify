# frozen_string_literal: true

require 'test_helper'

module Umedia
  class PurgeImageJobTest < ActiveJob::TestCase
    test 'purges an image' do
      skip('Why does this not enqueue a job?')
      assert_enqueued_jobs(1) do
        Umedia::PurgeImageJob.new('p16022coll262:173').perform_now
      end
    end

    test 'perform can fetch a SolrDocument' do
      document = SolrDocument.find('p16022coll262:173')
      assert_equal('p16022coll262:173', document.id)
    end
  end
end
