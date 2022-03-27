# frozen_string_literal: true

require 'test_helper'

module Umedia
  class ImageServiceTest < ActiveSupport::TestCase
    def setup
      @document = SolrDocument.find('p16022coll262:173')
      @service = Umedia::ImageService.new(@document)
    end

    test 'responds to instance methods' do
      assert_respond_to @service, :document
      assert_respond_to @service, :logger
      assert_respond_to @service, :store!
      assert_respond_to @service, :purge!

      assert_kind_of ActiveSupport::TaggedLogging, @service.logger
    end

    test 'stores an image' do
      assert_not(@document.sidecar.image.attached?)
      @service.store!
      assert_predicate(@document.sidecar.image, :attached?)
    end

    test 'purges an image' do
      assert_not(@document.sidecar.image.attached?)
      @service.store!
      @document.sidecar.image.purge
      assert_not(@document.sidecar.image.attached?)
    end

    test 'that image_tempfile creates a tempfile' do
      tempfile = @service.send('image_tempfile', @document.id)
      assert_kind_of Tempfile, tempfile
    end

    test 'image_url' do
      assert_equal('https://cdm16022.contentdm.oclc.org/utils/getthumbnail/collection/p16022coll262/id/173', @service.document['object_ssi'])
    end

    test 'timeout' do
      assert_equal(30, @service.send('timeout'))
    end
  end
end
