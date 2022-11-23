namespace :umedia do
  namespace :solr do
    desc 'Dump all Solr docs to JSON file (optional env EXPORT_FILENAME=path/to/file.json.gz)'
    task export_data: :environment do
      require 'open-uri'
      require 'jq'
      require 'zlib'

      # Accepts 1 argument specifying the filename to write
      exportfile = (ENV['EXPORT_FILENAME'] || "#{Rails.root}/umedia-solr-dump.json.gz").chomp

      # Use a raw HTTP call into JQ instead of SolrDocument because it is WAY faster
      jsondata = URI.open("#{ENV['SOLR_URL']}/select?q=*:*&fl=*&rows=999999&wt=json").read

      # Parse the JSON and write the results (without solr response metadata or doc versioning)
      # back to an export file
      exportdocs = JQ(jsondata).search('del(.response.docs[]["_version_", "score", "timestamp"]) | .response.docs[]')
      puts "Writing JSON file: #{exportfile}..."
      Zlib::GzipWriter.open(exportfile) do |gz|
        gz.write exportdocs.to_json
      end
      puts "Done."
    end

    # Takes the current state of the development Solr index and dumps it
    # out to test/fixtures/dev-solr-index.json for use with testing.
    # Be sure to commit changes
    desc 'Update Solr fixtures file with the current index state'
    task update_fixtures: :environment do
      ENV['EXPORT_FILENAME'] = "#{Rails.root}/test/fixtures/dev-solr-index.json.gz"
      Rake::Task['umedia:solr:export_data'].invoke
      puts "Don't forget to commit the modified fixtures to source control."
    end

    desc 'Delete ALL documents from solr index at $SOLR_URL. (env WIPE_DATA=1 to skip prompts)'
    task wipe_data: :environment do
      require 'rsolr'

      puts "Deleting all documents from Solr at #{ENV['SOLR_URL']}"
      puts "Press y to confirm (pass env WIPE_DATA=1 to bypass)..." unless ENV['WIPE_DATA']
      if ENV['WIPE_DATA'] || $stdin.gets.chomp.downcase == 'y'
        solr = RSolr.connect url: ENV['SOLR_URL']
        solr.delete_by_query '*:*'
        solr.commit
      else
        puts "Action canceled."
        exit
      end
    end

    desc 'Populate a development Solr index from JSON fixtures (Optional env filename IMPORT_FILENAME=path/to/file.json, skip prompts with WIPE_DATA=1)'
    task index_dev: [:environment, :wipe_data] do
      importfile = (ENV['EXPORT_FILENAME'] || "#{Rails.root}/test/fixtures/dev-solr-index.json.gz")

      # Run Solr's bin/post with the inupt JSON, probably the fastest way of indexing
      puts "Importing from #{importfile}..."
      system("gunzip -c '#{importfile}' | #{Rails.root}/tmp/solr/bin/post -url '#{ENV['SOLR_URL']}/update' -commit yes -type application/json -d")
    end
  end
end
