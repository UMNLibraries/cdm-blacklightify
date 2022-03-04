# frozen_string_literal: true

module Umedia
  # ViewerMap
  class ViewerMap
    attr_reader :record

    def initialize(record: {})
      @record = record
    end

    def viewer
      kaltura_mapping || format_mapping
    end

    private

    def kaltura_mapping
      @kaltura_mapping ||= kaltura_mappings.map do |mapping|
        mapping[:viewer] if record.fetch(mapping[:field], {}) != {}
      end.compact.first
    end

    def format_mapping
      case format
      when 'jpg', 'jp2'
        'image'
      when 'pdf'
        'pdf'
      when 'cpd'
        'COMPOUND_PARENT_NO_VIEWER'
      else
        raise "Unknown viewer format: #{format}"
      end
    end

    def format
      record.fetch('find', '').split('.').last
    end

    def mappings
      [
        { 'jp2' => 'image' },
        { 'pdf' => 'pdf' }
      ]
    end

    # Order matters here: if there is a playlist, there will also be audio, but
    # we just want the playlist.
    def kaltura_mappings
      [
        { field: 'kaltud', viewer: 'kaltura_combo_playlist' },
        { field: 'kaltua', viewer: 'kaltura_audio_playlist' },
        { field: 'kaltuc', viewer: 'kaltura_video_playlist' },
        { field: 'kaltur', viewer: 'kaltura_audio' },
        { field: 'kaltub', viewer: 'kaltura_video' }
      ]
    end
  end
end
