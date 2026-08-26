# frozen_string_literal: true

##
# KalturaHelper
module KalturaHelper
  def kaltura_video_url
    "#{kaltura_base_url}/p/#{kaltura_partner_id}/embedPlaykitJs/uiconf_id/#{kaltura_uiconf_id}"
  end

  def kaltura_audio_url
    kaltura_video_url
  end

  private

  def kaltura_settings
    @kaltura_settings ||= Rails.application.config_for(:kaltura).with_indifferent_access
  end

  def kaltura_base_url
    ENV.fetch('KALTURA_URL', kaltura_settings[:url]).to_s
  end

  def kaltura_partner_id
    ENV.fetch('KALTURA_PARTNER_ID', kaltura_settings[:partner_id]).to_s
  end

  def kaltura_uiconf_id
    ENV.fetch('KALTURA_UICONF_ID', kaltura_settings[:uiconf_id]).to_s
  end
end
