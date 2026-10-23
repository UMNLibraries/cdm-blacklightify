require 'net/http'
require 'json'

class CollectionNameResolver
  attr_reader :set_spec

  def initialize(set_spec)
    @set_spec = set_spec
  end

  def resolve
    return nil if set_spec.blank?

    query_solr
  end

  private

  def query_solr
    uri = build_solr_uri
    response = fetch_from_solr(uri)
    parse_collection_name(response)
  end

  def build_solr_uri
    solr_url = ENV.fetch('SOLR_URL', 'http://localhost:8983/solr/blacklight-core')
    uri = URI("#{solr_url}/select")
    uri.query = URI.encode_www_form(
      q: "set_spec:#{set_spec}",
      fl: 'collection_name_s',
      rows: 1,
      wt: 'json'
    )
    uri
  end

  def fetch_from_solr(uri)
    Net::HTTP.get(uri)
  rescue StandardError => e
    Rails.logger.error("Error querying Solr for collection_name_s: #{e.message}")
    nil
  end

  def parse_collection_name(response)
    return nil if response.blank?

    data = JSON.parse(response)
    data.dig('response', 'docs', 0, 'collection_name_s')
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing Solr response: #{e.message}")
    nil
  end
end
