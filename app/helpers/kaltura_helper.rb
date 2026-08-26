# frozen_string_literal: true

require 'uri'

##
# KalturaHelper
module KalturaHelper
  def kaltura_video_url(entry_id)
    kaltura_embed_url(entry_id: entry_id)
  end

  def kaltura_audio_url(entry_id)
    kaltura_embed_url(entry_id: entry_id)
  end

  def kaltura_audio_playlist_url(playlist_id)
    kaltura_embed_url(playlist_id: playlist_id)
  end

  private

  def kaltura_settings
    @kaltura_settings ||= Rails.application.config_for(:kaltura).with_indifferent_access
  end

  def kaltura_base_url
    kaltura_settings[:url].to_s
  end

  def kaltura_partner_id
    kaltura_settings[:partner_id].to_s
  end

  def kaltura_uiconf_id
    kaltura_settings[:uiconf_id].to_s
  end

  def kaltura_embed_url(entry_id: nil, playlist_id: nil)
    query = { iframeembed: true }
    query[:entry_id] = entry_id if entry_id.present?
    query[:playlist_id] = playlist_id if playlist_id.present?

    "#{kaltura_base_url}/p/#{kaltura_partner_id}/embedPlaykitJs/uiconf_id/#{kaltura_uiconf_id}?#{URI.encode_www_form(query)}"
  end
end
