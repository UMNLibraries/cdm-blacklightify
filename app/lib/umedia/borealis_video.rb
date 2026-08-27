# frozen_string_literal: true

module Umedia
  # BorealisVideo
  class BorealisVideo < BorealisAsset
    include KalturaHelper
    def src(entry_id = nil)
      entry_id ||= (playlist_id || video_id)
      kaltura_video_playmanifest_url(entry_id)
    end

    def thumbnail_url
      Umedia::Thumbnail::DEFAULT_VIDEO_URL
    end

    def downloads
      []
    end

    def type
      playlist_id ? 'kaltura_video_playlist' : 'kaltura_video'
    end

    def video_id
      document.fetch('kaltura_video_ssi', false)
    end

    def video_playlist_id
      document.fetch('kaltura_video_playlist_ssi', false)
    end

    def audio_playlist_id
      document.fetch('kaltura_audio_playlist_ssi', false)
    end

    def playlist_id
      video_playlist_id || audio_playlist_id
    end

    def playlist_data
      data = document.fetch('kaltura_video_playlist_entry_data_ts', '[]')
      JSON.parse(data)
    end

    def playlist?
      type == 'kaltura_video_playlist'
    end

    def viewer
      Umedia::BorealisVideoPlayer
    end
  end
end
