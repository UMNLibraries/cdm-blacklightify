# frozen_string_literal: true

module Umedia
  # DocumentAnchor
  class DocumentAnchor
    attr_reader :doc, :search_text, :document_klass

    def initialize(doc: {}, search_text: false, document_klass: BorealisDocument)
      @doc = doc
      @search_text = search_text
      @document_klass = document_klass
    end

    def anchor
      case document_klass.new(document: doc).first_key
      when 'image'
        "/image/0#{search}"
      when 'kaltura_video'
        '/kaltura_video'
      when 'kaltura_audio'
        '/kaltura_audio'
      when 'pdf'
        '/pdf/0'
      else
        ''
      end
    end

    def search
      "?searchText=#{search_text}" if search_text
    end
  end
end
