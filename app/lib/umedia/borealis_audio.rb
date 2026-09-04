# frozen_string_literal: true

module Umedia
  # BorealisAudio
  class BorealisAudio < BorealisAsset
    include KalturaHelper
    def src(entry_id = audio_id)
      kaltura_audio_playmanifest_url(entry_id)
    end

    def thumbnail_url
      Umedia::Thumbnail::DEFAULT_AUDIO_URL
    end

    def downloads
      []
    end

    def viewer
      Umedia::BorealisAudioPlayer
    end

    def type
      audio_playlist_id ? 'kaltura_audio_playlist' : 'kaltura_audio'
    end

    def audio_playlist_id
      document.fetch('kaltura_audio_playlist_ssi', false)
    end

    def audio_id
      document.fetch('kaltura_audio_ssi', false)
    end

    def playlist_data
      data = document.fetch('kaltura_audio_playlist_entry_data_ts', '[]')
      JSON.parse(data)
    end

    def playlist?
      type == 'kaltura_audio_playlist'
    end
  end
end
