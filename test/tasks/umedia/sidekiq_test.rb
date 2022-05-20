# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SidekiqTaskTest < ActiveSupport::TestCase
  describe 'rake umedia:sidekiq' do
    def setup
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end

    it ':stats - should return sidekiq stats' do
      Rake::Task['umedia:sidekiq:stats'].invoke
      stats = Sidekiq::Stats.new
      assert_kind_of Sidekiq::Stats, stats
    end

    it ':clear_queues - clear all sidekiq queues' do
      Rake::Task['umedia:sidekiq:clear_queues'].invoke
      stats = Sidekiq::Stats.new
      assert_equal(0, stats.enqueued)
    end
  end
end
