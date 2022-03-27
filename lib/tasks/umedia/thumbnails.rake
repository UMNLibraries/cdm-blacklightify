# frozen_string_literal: true

require 'rsolr'

# Task Solr Query
class TaskSolrQuery
  # Space delimited
  # Ex. doc_ids = 'p16022coll208:0 p16022coll208:1'
  def scoped(doc_ids)
    Blacklight.default_index.connection.get 'select', params: { q: "+(#{build_query(doc_ids)})", rows: '1000000' }
  end

  def global
    Blacklight.default_index.connection.get 'select', params: { q: '*:*', rows: '1000000' }
  end

  def build_query(doc_ids)
    "+(#{doc_ids.gsub(':', '\:').split.join(' OR ')})"
  end
end

namespace :umedia do
  namespace :thumbnails do
    desc 'Harvest/Store SolrDocument thumbnails - DOC_IDS=\'1,3,4\' (optional)'
    task store: :environment do
      query = TaskSolrQuery.new

      response = ENV['DOC_IDS'].present? ? query.scoped(ENV.fetch('DOC_IDS', nil)) : query.global

      @steps = 0

      response['response']['docs'].each do |document|
        Umedia::StoreImageJob.perform_later(document['id'])
        @steps += 1
      end

      puts "Thumbnail storage jobs created: #{@steps}"
    end

    desc 'Purge SolrDocument thumbnails.'
    task purge: :environment do
      query = TaskSolrQuery.new

      response = ENV['DOC_IDS'].present? ? query.scoped(ENV.fetch('DOC_IDS', nil)) : query.global

      @steps = 0

      response['response']['docs'].each do |document|
        Umedia::PurgeImageJob.perform_later(document['id'])
        @steps += 1
      end

      puts "Thumbnail purge jobs created: #{@steps}"
    end
  end
end
