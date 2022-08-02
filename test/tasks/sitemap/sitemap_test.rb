# frozen_string_literal: true

require 'rake'
require 'sitemap_generator'
require 'test_helper'
require 'zlib'

# integrate sitemap test into Rails test suite
class SitemapGeneratorTest < ActiveSupport::TestCase
  describe 'rake sitemap:create' do
    def setup
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end
    it ':create - tests sitemap generation' do
      capture_io do
        Rake::Task['sitemap:create'].invoke
      end
      # Test a known item is mapped within the file
      sitemap_data = Zlib::GzipReader.open('tmp/sitemap-test.xml.gz').read
      assert_match '<loc>https://umedia.lib.umn.edu/item/p16022coll171:7</loc>', sitemap_data
    end
    def teardown
      File.exist?('tmp/sitemap-test.xml.gz') && File.delete('tmp/sitemap-test.xml.gz')
    end
  end
end
