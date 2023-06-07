# frozen_string_literal: true

namespace :umedia do
  namespace :sidekiq do
    desc 'Check sidekiq stats'
    task stats: :environment do
      # Check stats
      puts sidekiq_format_stats Sidekiq::Stats.new
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

      puts sidekiq_format_stats(stats)
    end

    def sidekiq_format_stats(stats)
      <<~SQSTATS
        Sidekiq status & stats
        ----------------------
        Queued (default) #{stats.queues['default']}
        Processed:       #{stats.processed}
        Failed:          #{stats.failed}
        Scheduled:       #{stats.scheduled_size}
        Retry:           #{stats.retry_size}
        Dead:            #{stats.dead_size}
        Num Processes:   #{stats.processes_size}
      SQSTATS
    end
  end
end
