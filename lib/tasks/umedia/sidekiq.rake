# frozen_string_literal: true

namespace :umedia do
  namespace :sidekiq do
    desc 'Check sidekiq stats'
    task stats: :environment do
      # Check stats
      stats = Sidekiq::Stats.new
      puts stats.inspect
    end

    desc 'Clear sidekiq queues'
    task clear_queues: :environment do
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
      Sidekiq::Stats.new.reset
      Sidekiq::DeadSet.new.clear

      stats = Sidekiq::Stats.new
      stats.queues
      stats.queues.count
      stats.queues.clear

      queue = Sidekiq::Queue.new('default')
      queue.each(&:delete)

      puts stats.inspect
    end
  end
end
