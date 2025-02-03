module DownloadHelper
  include Umedia
  
  def download_path
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}/filename/print/page/download/fparams/forcedownload" :
    # image
    "https://cdm16022.contentdm.oclc.org/utils/getstream/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}"
  end

  def type_selector
    @document[:kaltura_audio] ? 
      # audio
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_audio] + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4' : 
      # video
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_video] + '/flavorId/1_uivmmxof/format/url/protocol/http/a.mp4'
  end
end
