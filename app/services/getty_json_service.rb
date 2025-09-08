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

  # get the format id, use that key for caching
  def att_def_id
    aat_data['id'].match('aat\/(.*)')&.captures[0] 
  end

  def att_definition
    Rails.cache.fetch(att_def_id) do
      aat_data['subject_of'][0]['content']
    end 
  end
end