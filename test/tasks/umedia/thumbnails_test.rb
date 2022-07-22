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

      out, = capture_io do
        Rake::Task['umedia:thumbnails:store'].invoke
      end
      assert_equal 'Thumbnail storage jobs created: 1', out.strip
    end

    it 'purge - should purge a thumbnail image for a single doc' do
      ENV['DOC_IDS'] = 'p16022coll262:173'

      out, = capture_io do
        Rake::Task['umedia:thumbnails:purge'].invoke
      end
      assert_equal 'Thumbnail purge jobs created: 1', out.strip
    end
  end
end
