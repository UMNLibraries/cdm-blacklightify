class GettyJsonService
  def initialize(id)
    @id = id
  end

  def aat_data
    @res ||= Net::HTTP.get_response(URI( 'https://vocab.getty.edu/aat/' + @id + '.json' )).body
    JSON.parse(@res) rescue {}
  end

  # get the format id, use that key for caching
  def att_def_id
    aat_data.dig('id').match('aat\/(.*)')&.captures[0] rescue nil
  end

  def att_definition
    Rails.cache.fetch(att_def_id, expires_in: 30.days) do
      aat_data.dig('subject_of', 0, 'content')
    end 
  end

  def att_name
    aat_data.dig('_label')
  end
end
