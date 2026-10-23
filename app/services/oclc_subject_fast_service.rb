require 'nokogiri'
require 'open-uri'

class OclcSubjectFastService
  def initialize(id)
    @id = id
  end

  def fast_data
    # Check Rails cache first
    cache_key = "oclc_subject_fast:#{@id}"
    cached_result = Rails.cache.read(cache_key)
    return cached_result if cached_result.present?

    begin
      url = @id + '.rdf.xml'
      doc = Nokogiri::XML(URI.open(url, open_timeout: 3, read_timeout: 3))
      term = doc.xpath("//skos:prefLabel").collect(&:text)[0]
      term = @id if term.blank?
      
      # Cache the result for 24 hours
      Rails.cache.write(cache_key, term, expires_in: 24.hours)
      
      term
    rescue OpenURI::HTTPError, SocketError, Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
      Rails.logger.warn("[OclcSubjectFastService] FAST lookup failed for #{@id}: #{e.class} #{e.message}")
      # Fail gracefully to avoid breaking result rendering when FAST endpoint is unavailable.
      Rails.cache.write(cache_key, @id, expires_in: 1.hour)
      @id
    end
  end

  # if subject_fast field is entered as a term, not the oclc uri (may not be necessary)
  # leaving these in for dev purposes . . .
  def uri_check
    @id.downcase.include?("id.worldcat.org")
  end
end