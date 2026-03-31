require 'nokogiri'
require 'open-uri'

class OclcSubjectFastService
  def initialize(id)
    @id = id
  end

  def fast_data
    begin
      url = @id + '.rdf.xml'
      doc = Nokogiri::XML(URI.open(url))
      term = doc.xpath("//skos:prefLabel").collect(&:text)[0]
    # if uri returns 404 (may not be necessary)
    rescue OpenURI::HTTPError => e
      if e.message.include?('404')
        e.message
      else
        raise e
      end
    end
  end

  # if subject_fast field is entered as a term, not the oclc uri (may not be necessary)
  # leaving these in for dev purposes . . .
  def uri_check
    @id.downcase.include?("id.worldcat.org")
  end
end