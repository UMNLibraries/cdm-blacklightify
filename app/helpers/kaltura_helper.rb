# frozen_string_literal: true

require 'uri'

##
# KalturaHelper
module KalturaHelper
  def kaltura_single_embed_script_src
    kaltura_embed_iframe_js_url(uiconf_id: kaltura_player_uiconf_id_single)
  end

  def kaltura_compound_embed_script_src
    kaltura_embed_iframe_js_url(uiconf_id: kaltura_player_uiconf_id_compound)
  end

  def kaltura_video_url(entry_id)
    kaltura_embed_url(entry_id: entry_id)
  end

  def kaltura_audio_url(entry_id)
    kaltura_embed_url(entry_id: entry_id)
  end

  def kaltura_audio_playlist_url(playlist_id)
    kaltura_embed_url(playlist_id: playlist_id)
  end

  def kaltura_audio_playmanifest_url(entry_id)
    kaltura_playmanifest_url(entry_id: entry_id, flavor_id: kaltura_audio_flavor_id)
  end

  def kaltura_video_playmanifest_url(entry_id)
    kaltura_playmanifest_url(entry_id: entry_id, flavor_id: kaltura_video_flavor_id)
  end

  private

  def kaltura_playmanifest_url(entry_id:, flavor_id:)
    "#{kaltura_base_url}/p/#{kaltura_partner_id}/sp/#{kaltura_sub_partner_id}/playManifest/entryId/#{entry_id.strip}/flavorId/#{flavor_id}/format/url/protocol/http/a.mp4"
  end

  def kaltura_base_url
    ENV.fetch('KALTURA_URL', 'https://cdnapisec.kaltura.com')
  end

  def kaltura_partner_id
    ENV.fetch('KALTURA_PARTNER_ID')
  end

  def kaltura_sub_partner_id
    ENV.fetch('KALTURA_SUB_PARTNER_ID', "#{kaltura_partner_id}00")
  end

  def kaltura_uiconf_id
    ENV['KALTURA_UICONF_ID'] || kaltura_player_uiconf_id_single
  end

  def kaltura_player_uiconf_id_single
    ENV.fetch('KALTURA_PLAYER_UICONF_ID_SINGLE')
  end

  def kaltura_player_uiconf_id_compound
    ENV.fetch('KALTURA_PLAYER_UICONF_ID_COMPOUND')
  end

  def kaltura_embed_url(entry_id: nil, playlist_id: nil)
    query = { iframeembed: true }
    query[:entry_id] = entry_id if entry_id.present?
    query[:playlist_id] = playlist_id if playlist_id.present?

    "#{kaltura_base_url}/p/#{kaltura_partner_id}/embedPlaykitJs/uiconf_id/#{kaltura_uiconf_id}?#{URI.encode_www_form(query)}"
  end

  def kaltura_embed_iframe_js_url(uiconf_id:)
    "#{kaltura_base_url}/p/#{kaltura_partner_id}/sp/#{kaltura_sub_partner_id}/embedIframeJs/uiconf_id/#{uiconf_id}/partner_id/#{kaltura_partner_id}"
  end

  def kaltura_audio_flavor_id
    ENV.fetch('KALTURA_AUDIO_FLAVOR_ID', '1_atuqqpf6')
  end

  def kaltura_video_flavor_id
    ENV.fetch('KALTURA_VIDEO_FLAVOR_ID', '1_uivmmxof')
  end
end
