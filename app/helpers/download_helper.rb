module DownloadHelper
  include Umedia
  
  def download_path
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}/filename/print/page/download/fparams/forcedownload" :
    # image
    "https://cdm16022.contentdm.oclc.org/utils/getstream/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}"
  end
end
