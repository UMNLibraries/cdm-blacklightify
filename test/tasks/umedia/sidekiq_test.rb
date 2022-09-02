# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SidekiqTaskTest < ActiveSupport::TestCase
  describe 'rake umedia:sidekiq' do
    def setup
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end

    it ':stats - should return sidekiq stats' do
      out, = capture_io do
        Rake::Task['umedia:sidekiq:stats'].invoke
      end
      stats = Sidekiq::Stats.new
      assert_kind_of Sidekiq::Stats, stats
      assert_match(/Processed:\s+\d/, out)
    end

    it ':clear_queues - clear all sidekiq queues' do
      out, = capture_io do
        Rake::Task['umedia:sidekiq:clear_queues'].invoke
      end
      stats = Sidekiq::Stats.new
      assert_equal(0, stats.enqueued)
      assert_match(/Processed:\s+0/, out)
    end
  end
end
