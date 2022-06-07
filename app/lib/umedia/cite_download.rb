module Umedia
  class CiteDownload
    attr_reader :assets
    def initialize(assets: [])
      @assets = assets
    end

    def to_hash
      {
        focus: false,
        type: 'download',
        label: 'Download',
        fields: downloads.compact
      }
    end

    def downloads
      assets.map do |asset|
        unless asset.downloads.empty?
          {
            thumbnail: asset.thumbnail,
            sources: asset.downloads
          }
        end
      end
    end
  end
end
