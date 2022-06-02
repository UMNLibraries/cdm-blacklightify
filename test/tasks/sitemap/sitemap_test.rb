# frozen_string_literal: true

require 'rake'
require 'test_helper'

# integrate sitemap test into Rails test suite
class SitemapTaskTest < ActiveSupport::TestCase
  describe 'rake sitemap:test' do
    it ':test - will test sitemap generation' do
      Rake::Task['sitemap:test'].invoke
      Rake::Task['sitemap:test_clean'].invoke
    end
  end
end
