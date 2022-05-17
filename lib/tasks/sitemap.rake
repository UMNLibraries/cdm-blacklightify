# frozen_string_literal: true

namespace :sitemap
desc 'Test if sitemap generator runs successfully'
task test: :environment do
  # solr = ENV['SOLR_URL']
  if Rails.env.test?
    # execute the rake task to create the sitemap
    Rake::Task['sitemap:create'].invoke
    map_created = File.exist?('public/sitemap.xml.gz')
    map_hasdata = File.size('public/sitemap.xml.gz') > 10_000
    if map_created == true && map_hasdata == true
      puts 'sitemap creation successful'
    else
      puts 'sitemap creation failed'
    end
    File.delete('public/sitemap.xml.gz')
  end
end
