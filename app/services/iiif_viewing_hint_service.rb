class IiifViewingHintService
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def call
    iiif_manifest
  end

  private 

  def iiif_manifest
    response = "https://cdm16022.contentdm.oclc.org/iiif/2/" + id + "/manifest.json"
    res = Net::HTTP.get_response(URI(response))
    parsed_response = res.body
    parsed_response[-1] = ',"viewingHint":"paged"}'
    JSON.parse(parsed_response)
  end
end