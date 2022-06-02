# frozen_string_literal: true

namespace :sitemap do
  desc 'Test if sitemap generator runs successfully'
  task test: :environment do
    if Rails.env.test?
      # see config/sitemap.rb for test parameters
      Rake::Task['sitemap:create'].invoke
      map_created = File.exist?('tmp/sitemap-tmp.xml.gz')
      map_hasdata = File.size('tmp/sitemap-tmp.xml.gz') > 10_000
      if map_created == true && map_hasdata == true
        puts 'sitemap creation successful!'
      else
        puts 'sitemap creation failed!'
      end
    end
  end
  desc 'Delete the test sitemap'
  task test_clean: :environment do
    Rails.env.test? && File.exist?('tmp/sitemap-tmp.xml.gz') == true
    File.delete('tmp/sitemap-tmp.xml.gz')
  end
end
