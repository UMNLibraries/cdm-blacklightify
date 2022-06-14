# frozen_string_literal: true

require 'test_helper'
require 'rake'
require 'sitemap_generator'

# integrate sitemap test into Rails test suite
class SitemapGeneratorTest < ActiveSupport::TestCase
  describe 'rake sitemap:create' do
    def setup
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end
    it ':create - tests sitemap generation' do
      Rake::Task['sitemap:create'].invoke
      # test that it has data from solr
      has_data = "File.size?('tmp/sitemap-test.xml.gz') > 10_000"
      assert(has_data)
      Minitest.after_run { File.delete('tmp/sitemap-test.xml.gz') }
    end
  end
end
