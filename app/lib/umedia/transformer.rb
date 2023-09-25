# frozen_string_literal: true

require_relative './multi_date_formatter'

module Umedia
  # CDMBL field mappings
  class Transformer
    # Formatter to exclude Hash
    class RemoveHashFormatter
      def self.format(values)
        values unless values.is_a?(Hash)
      end
    end

    # Calculating the Borealis fragment is expensive, so it is precalculated
    # here
    class BorealisFragmentFormatter
      def self.format(doc)
        # This is pretty ugly. OK, it's heinous. I am not going to refactor the
        # Borealis code though, b/c my plan is to migrate Umedia to the new UMedia
        # platform and get rid of React altogether...partially b/c we can get
        # rid of a lot of this ugly config generation code
        doc = doc.merge('format_tesi' => doc.fetch('format')) unless doc.fetch('format').is_a?(Hash)

        compounds = (doc['page'].is_a?(Hash) ? [] : doc['page']).to_json
        doc = doc.merge('compound_objects_ts' => compounds)
        Umedia::DocumentAnchor.new(doc: doc).anchor
      end
    end

    # Kaltura Playlist Formatter
    class KalturaPlaylistDataFormatter
      def self.format(value)
        data = value.split(';').map do |playlist_entry_id|
          id = playlist_entry_id.strip
          entry = KalturaMediaEntryService.get(id)
          {
            entry_id: playlist_entry_id,
            duration: entry.duration,
            name: entry.name
          }
        end

        JSON.generate(data)
      end
    end

    def self.field_mappings
      Rails.application.config.field_mappings
    end
  end
end
