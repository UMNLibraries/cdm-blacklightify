# frozen_string_literal: true

require 'rake'
require 'sitemap_generator'
require 'test_helper'

# integrate sitemap test into Rails test suite
class SitemapGeneratorTest < ActiveSupport::TestCase
  describe 'rake sitemap:create' do
    def setup
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end
    it ':create - tests sitemap generation' do
      Rake::Task['sitemap:create'].invoke
      # test that it has data from solr
      sitemap_has_data = "File.size?('tmp/sitemap-test.xml.gz') > 10_000"
      assert(sitemap_has_data)
    end
    def teardown
      File.exist?('tmp/sitemap-test.xml.gz') && File.delete('tmp/sitemap-test.xml.gz')
    end
  end
end
