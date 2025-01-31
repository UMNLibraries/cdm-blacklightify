module DownloadHelper
  include Umedia
  
  def download_path
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@document[:id].split(':')[0]}/id/#{@document[:id].split(':')[1]}/filename/print/page/download/fparams/forcedownload"
  end
end
