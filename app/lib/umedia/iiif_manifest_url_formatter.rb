# frozen_string_literal: true

module Umedia
  # IiifManifestUrlFormatter
  class IiifManifestUrlFormatter
    class << self
      def format(doc)
        collection, id = doc['id'].split('/')
        "/iiif/#{collection}:#{id}/manifest.json"
      end
    end
  end
end
