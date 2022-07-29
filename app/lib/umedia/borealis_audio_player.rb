# frozen_string_literal: true

module Umedia
  # BorealisAudioPlayer
  class BorealisAudioPlayer < BorealisAssetsViewer
    def to_viewer
      asset.audio_playlist_id ? playlist : player
    end

    def player
      {
        'type' => asset.type,
        'targetId' => 'kaltura_player',
        'wid' => "_#{ENV.fetch('KALTURA_PARTNER_ID')}",
        'uiconf_id' => ENV.fetch('KALTURA_PLAYER_UICONF_ID_SINGLE'),
        'entry_id' => asset.audio_id,
        'transcript' => {
          'texts' => asset.transcripts,
          'label' => 'Audio'
        },
        'wrapper_height' => '100%',
        'wrapper_width' => '100%',
        'thumbnail' => '/images/audio-3.png'
      }
    end

    def playlist
      {
        'type' => 'kaltura_audio_playlist',
        'targetId' => 'kaltura_player_playlist',
        'wid' => "_#{ENV.fetch('KALTURA_PARTNER_ID')}",
        'uiconf_id' => ENV.fetch('KALTURA_PLAYER_UICONF_ID_COMPOUND'),
        'flashvars' => {
          'streamerType' => 'auto',
          'playlistAPI.kpl0Id' => asset.audio_playlist_id
        },
        'transcript' => {
          'texts' => asset.transcripts,
          'label' => 'Audio Playlist'
        },
        'wrapper_height' => '100%',
        'wrapper_width' => '100%',
        'thumbnail' => '/images/audio-3.png'
      }
    end
  end
end
