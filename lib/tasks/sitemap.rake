# frozen_string_literal: true

namespace :sitemap do
  desc 'Test if sitemap generator runs successfully'
  task test: :environment do
    if Rails.env.test?
      # when in the test environment, the sitemap is created as 'tmp/sitemap-tmp.xml.gz'
      Rake::Task['sitemap:create'].invoke
      # see config/sitemap.rb for test paramet
      map_created = File.exist?('tmp/sitemap-tmp.xml.gz')
      map_hasdata = File.size('tmp/sitemap-tmp.xml.gz') > 10_000
      if map_created == true && map_hasdata == true
        puts 'sitemap creation successful!'
      else
        puts 'sitemap creation failed!'
      end
      File.delete('tmp/sitemap-tmp.xml.gz')
    end
  end
end
