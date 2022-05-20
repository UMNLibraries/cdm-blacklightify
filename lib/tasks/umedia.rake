# frozen_string_literal: true

require 'bundler/audit/task'
Bundler::Audit::Task.new

task default: 'bundle:audit'

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

desc 'Run test suite'
task ci: :environment do
  success = true
  system('bundle exec rake umedia:index:seed') || success = false
  system('RAILS_ENV=test bundle exec rails test:system test') || success = false
  system('bundle exec rake bundle:audit') || success = false
  exit!(1) unless success
end

namespace :test do
  desc 'Run tests with coverage'
  task coverage: :environment do
    require 'simplecov'
    SimpleCov.start 'rails'

    Rake::Task['test'].invoke
  end
end

namespace :umedia do
  namespace :index do
    desc 'Put all sample data into solr'
    task seed: :environment do
      docs = Dir['test/fixtures/files/solr_documents/*.json'].map { |f| JSON.parse File.read(f) }.flatten
      Blacklight.default_index.connection.add docs
      Blacklight.default_index.connection.commit
    end

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
          'solr_config' => { url: ENV.fetch('SOLR_URL', nil) },
          'oai_endpoint' => ENV.fetch('OAI_ENDPOINT', nil),
          'cdm_endpoint' => ENV.fetch('CDM_ENDPOINT', nil),
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
      solr = ENV.fetch('SOLR_URL', nil)
      replication = 'replication?command=backup'

      res = Faraday.get "#{solr}/#{replication}"
      puts res.body

      sleep(10)

      snapshots = Dir.glob(Rails.root.join('tmp/solr/server/solr/blacklight-core/data/snapshot.*').to_s)

      FileUtils.cp_r(snapshots, Rails.root.join('solr/snapshots').to_s)
    end

    desc 'Restore'
    task restore: :environment do
      solr = ENV.fetch('SOLR_URL', nil)
      replication = 'replication?command=restore'

      snapshot = Dir.glob(Rails.root.join('solr/snapshots/snapshot.*').to_s).last

      FileUtils.cp_r(snapshot, Rails.root.join('tmp/solr/server/solr/blacklight-core/data').to_s)

      res = Faraday.get "#{solr}/#{replication}"
      puts res.body
    end

    desc 'Start solr server for testing.'
    task test: :environment do
      if Rails.env.test?
        shared_solr_opts = { managed: true, verbose: true, persist: false, download_dir: 'tmp' }
        shared_solr_opts[:version] = ENV.fetch('SOLR_VERSION', nil) if ENV['SOLR_VERSION']

        SolrWrapper.wrap(shared_solr_opts.merge(port: 8983, instance_dir: 'tmp/blacklight-core')) do |solr|
          solr.with_collection(name: 'blacklight-core', dir: Rails.root.join('solr/conf').to_s) do
            puts 'Solr running at http://localhost:8983/solr/#/blacklight-core/, ^C to exit'
            begin
              Rake::Task['umedia:index:seed'].invoke
              sleep
            rescue Interrupt
              puts "\nShutting down..."
            end
          end
        end
      else
        system('rake umedia:index:test RAILS_ENV=test')
      end
    end
  end
end
