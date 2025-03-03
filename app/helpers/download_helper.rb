module DownloadHelper
  include Umedia
  
  def download_path
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}/filename/print/page/download/fparams/forcedownload" :
    # image
    # "https://cdm16022.contentdm.oclc.org/utils/getstream/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}"
    "https://cdm16022.contentdm.oclc.org/iiif/2/#{@document[:id]}/full/!3200,3200/0/default.jpg"
  end

  def type_selector
    @document[:kaltura_audio] ? 
      # audio
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_audio] + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4' : 
      # video
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_video] + '/flavorId/1_uivmmxof/format/url/protocol/http/a.mp4'
  end

  def playlist
  # playlist ? it is an older embed frame ? @document[:kaltura_audio_playlist]
  # if unable to execute on playlist download, will need logic to not present link for such items . . . can just look for kaltura_audio_playlist field . . .
  # 'https://cdnapi.kaltura.com/html5/html5lib/v2.50/mwEmbedFrame.php/p/2311101/uiconf_id/41902002/entry_id/1_89r40of6?wid=_1369852'

    # check if kaltura_audio_playlist field is present
    @document[:kaltura_audio_playlist] != nil

  end

  def single_embed
    if playlist == true
      'https://cdnapi.kaltura.com/html5/html5lib/v2.50/mwEmbedFrame.php/p/2311101/uiconf_id/41902002/entry_id/' + @document[:kaltura_audio_playlist] + '?wid=_1369852'
    end
  end
end
