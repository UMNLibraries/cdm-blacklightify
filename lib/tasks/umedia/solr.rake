# frozen_string_literal: true
#
require 'fileutils'

namespace :umedia do
  namespace :solr do
    desc 'Dump all Solr docs to JSON file (optional env EXPORT_FILENAME=path/to/file.json.gz)'
    task export_data: :environment do
      require 'open-uri'
      require 'jq'
      require 'zlib'

      # Rubocop does not like URI.open & kin but it's safe in a task like this
      # rubocop:disable Security/Open
      # Accepts 1 argument specifying the filename to write
      exportfile = (ENV.fetch('EXPORT_FILENAME') || Rails.root.join('umedia-solr-dump.json.gz')).chomp

      # Use a raw HTTP call into JQ instead of SolrDocument because it is WAY faster
      jsondata = URI.open("#{ENV.fetch('SOLR_URL')}/select?q=*:*&fl=*&rows=999999&wt=json").read

      # Parse the JSON and write the results (without solr response metadata or doc versioning)
      # back to an export file
      exportdocs = JQ(jsondata).search('del(.response.docs[]["_version_", "score", "timestamp"]) | .response.docs[]')
      puts "Writing JSON file: #{exportfile}..."
      Zlib::GzipWriter.open(exportfile) do |gz|
        gz.write exportdocs.to_json
      end
      puts 'Done.'
      # rubocop:enable Security/Open
    end

    # Takes the current state of the development Solr index and dumps it
    # out to test/fixtures/dev_solr_harvest.json for use in development
    # Be sure to commit changes
    desc 'Update Solr fixtures file with the current index state'
    task update_fixtures: :environment do
      ENV['EXPORT_FILENAME'] = Rails.root.join('test/fixtures/dev_solr_harvest.json.gz')
      Rake::Task['umedia:solr:export_data'].invoke
      puts "Don't forget to commit the modified fixtures to source control."
    end

    desc 'Delete ALL documents from solr index at $SOLR_URL. (env WIPE_DATA=1 to skip prompts)'
    task wipe_data: :environment do
      require 'rsolr'

      puts "Deleting all documents from Solr at #{ENV.fetch('SOLR_URL', nil)}"
      puts 'Press y to confirm (pass env WIPE_DATA=1 to bypass)...' unless ENV['WIPE_DATA']
      if ENV.fetch('WIPE_DATA', nil) || $stdin.gets.chomp.downcase == 'y'
        solr = RSolr.connect url: ENV.fetch('SOLR_URL', nil)
        solr.delete_by_query '*:*'
        solr.commit
      else
        puts 'Action canceled.'
        exit
      end
    end

    # Fills your Solr index very quickly with a sizable set of documents,
    # more expansive than the small set of fixtures needed for tests to pass
    # This is handy when you don't wish to wait for a harvest to finish
    #
    # Rubocop is not satisfiable within the system() call, oh well
    # rubocop:disable Rails/FilePath
    desc 'Populate a development Solr index from JSON fixtures (Optional env filename IMPORT_FILENAME=path/to/file.json, skip prompts with WIPE_DATA=1)'
    task index_dev: %i[environment wipe_data] do
      importfile = (ENV.fetch('EXPORT_FILENAME', nil) || Rails.root.join('test/fixtures/dev_solr_harvest.json.gz'))

      # Run Solr's bin/post with the inupt JSON, probably the fastest way of indexing
      FileUtils.chmod('+x', 'tmp/solr/bin/post')
      puts "Importing from #{importfile}..."
      system("gunzip -c '#{importfile}' | #{Rails.root.join('tmp/solr/bin/post')} -url '#{ENV.fetch('SOLR_URL')}/update' -commit yes -type application/json -d")
    end
    # rubocop:enable Rails/FilePath
  end
end
