require 'nokogiri'

class OclcSubjectFastService
  def initialize(id)
    @id = id
  end

  def fast_data
    url = @id + '.rdf.xml'
    doc = Nokogiri::XML(URI.open(url))
    term = doc.xpath("//skos:prefLabel").collect(&:text)[0]
  end  
end