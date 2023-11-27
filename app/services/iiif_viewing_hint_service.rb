class IiifViewingHintService
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def call
    appended_iiif_manifest
  end

  private 

  def appended_iiif_manifest
    url = "https://cdm16022.contentdm.oclc.org/iiif/2/" + id + "/manifest.json"
    res = Net::HTTP.get_response(URI(url))
    parsed_response = res.body
    parsed_response[-1] = ',"viewingHint":"paged"}'
    JSON.parse(parsed_response)
  end
end