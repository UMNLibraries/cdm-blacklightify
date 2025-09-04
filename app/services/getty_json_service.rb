class GettyJsonService
  def initialize(id)
    @id = id
  end

  def aat_data
    url = 'https://vocab.getty.edu/aat/' + @id + '.json'
    res = Net::HTTP.get_response(URI(url))
    parsed_response = res.body
    JSON.parse(parsed_response)
  end  
end