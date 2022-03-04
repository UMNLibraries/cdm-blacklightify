# frozen_string_literal: true

require 'bundler/audit/task'
Bundler::Audit::Task.new

task default: 'bundle:audit'

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

desc 'Run test suite'
task ci: :environment do
  success = true
  system('RAILS_ENV=test bundle exec rails test:system test') || success = false
  system('bundle exec rake bundle:audit') || success = false
  exit!(1) unless success
end

namespace :umedia do
  namespace :index do
    desc 'Harvest'
    task harvest: :environment do
      # mpls          => MDL collection
      # p16022coll262 => UMedia video collection
      # p16022coll208 => UMedia WWII poster collection
      # p16022coll171 => UMedia audio collection
      # p16022coll282 => UMedia compound objects (ex. p16022coll282:6571)

      example_sets = %w[
        p16022coll262 p16022coll208 p16022coll171 p16022coll282
      ]

      example_sets.each do |set|
        CDMDEXER::ETLWorker.new.perform(
          'solr_config' => { url: ENV['SOLR_URL'] },
          'oai_endpoint' => ENV['OAI_ENDPOINT'],
          'cdm_endpoint' => ENV['CDM_ENDPOINT'],
          'set_spec' => set,
          'batch_size' => 10,
          'max_compounds' => 10
        )
      end
    end

    desc 'Commit'
    task commit: :environment do
      Blacklight.default_index.connection.commit
    end

    desc 'Backup'
    task backup: :environment do
      solr = ENV['SOLR_URL']
      replication = 'replication?command=backup'

      res = Faraday.get "#{solr}/#{replication}"
      puts res.body

      sleep(10)

      snapshots = Dir.glob(Rails.root.join('tmp/solr/server/solr/blacklight-core/data/snapshot.*').to_s)

      FileUtils.cp_r(snapshots, Rails.root.join('solr/snapshots').to_s)
    end

    desc 'Restore'
    task restore: :environment do
      solr = ENV['SOLR_URL']
      replication = 'replication?command=restore'

      snapshot = Dir.glob(Rails.root.join('solr/snapshots/snapshot.*').to_s).last

      FileUtils.cp_r(snapshot, Rails.root.join('tmp/solr/server/solr/blacklight-core/data').to_s)

      res = Faraday.get "#{solr}/#{replication}"
      puts res.body
    end
  end

  namespace :sidekiq do
    desc 'Clear Queues'
    task clear_queues: :environment do
      require 'sidekiq/api'
      Sidekiq::Queue.all.each(&:clear)
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
      Sidekiq::DeadSet.new.clear
    end
  end
end
