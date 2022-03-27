# frozen_string_literal: true

require 'test_helper'
require 'rake'

class ThumbnailsTaskTest < ActiveSupport::TestCase
  describe 'rake umedia:thumbnails' do
    def setup
      @document = SolrDocument.find('p16022coll262:173')
      Umedia::Application.load_tasks if Rake::Task.tasks.empty?
    end

    it ':store - should store a thumbnail image for a single doc' do
      ENV['DOC_IDS'] = 'p16022coll262:173'
      Rake::Task['umedia:thumbnails:store'].invoke
    end

    it 'purge - should purge a thumbnail image for a single doc' do
      ENV['DOC_IDS'] = 'p16022coll262:173'
      Rake::Task['umedia:thumbnails:purge'].invoke
    end
  end
end
