# frozen_string_literal: true

##
# KalturaHelper
module KalturaHelper

  settings = Rails.application.config_for(:kaltura)

  BASE_URL = settings[:url]
  PARTNER_ID = settings[:partner_id].to_s
  UICONF_ID = settings[:uiconf_id].to_s
  
  def kaltura_video_url
    BASE_URL + '/p/' + PARTNER_ID + '/embedPlaykitJs/uiconf_id/' + UICONF_ID
  end

  def kaltura_audio_url
    kaltura_video_url
  end  
end
