# frozen_string_literal: true

require 'sitemap_generator'

# set the correct hostname
SitemapGenerator::Sitemap.default_host = 'https://umedia.lib.umn.edu'

# setting correct solr instance in config/blacklight.yaml
solrinst = RSolr.connect url: Blacklight.connection_config[:url]

# grab primary items and the dates they were last modified
response = solrinst.get('select', params: { q: 'record_type_ssi:primary', fl: 'id,dmmodified_ssi', rows: 9_999_999 })

# including the routes already defined in Rails and Spotlight
SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

# create the sitemap itself
SitemapGenerator::Sitemap.create do
  response['response']['docs'].each do |doc|
    add "/item/#{doc['id']}", changefreq: 'weekly', lastmod: doc['dmmodified_ssi']
  end
  Spotlight::Sitemap.add_all_exhibits(self)
end
