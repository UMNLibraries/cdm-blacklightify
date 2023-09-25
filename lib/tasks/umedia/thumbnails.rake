# frozen_string_literal: true

require 'rsolr'

# Task Solr Query
class TaskSolrQuery
  # Space delimited
  # Ex. doc_ids = 'p16022coll208:0 p16022coll208:1'
  def scoped(doc_ids)
    select query: "+(#{build_query(doc_ids)})", rows: doc_ids.split.length
  end

  def global
    select rows: total_docs
  end

  def all_primary
    select_primary rows: total_docs
  end

  def build_query(doc_ids)
    "+(#{doc_ids.gsub(':', '\:').split.join(' OR ')})"
  end

  def total_docs
    select['response']['numFound']
  end

  def total_primary_docs
    select_primary['response']['numFound']
  end

  def select(query: '*:*', rows: '1', fields: 'id')
    Blacklight.default_index.connection.get 'select', params: { q: query, rows: rows, fl: fields }
  end

  def select_primary(query: '*:*', rows: '1', fields: 'id')
    select(query: "#{query} AND record_type_ssi:primary", rows: rows, fields: fields)
  end
end

namespace :umedia do
  namespace :thumbnails do
    desc 'Harvest/Store SolrDocument thumbnails - DOC_IDS=\'1,3,4\' (optional)'
    task store: :environment do
      query = TaskSolrQuery.new

      # We are only storing thumbnails locally for "primary" record types, never for the
      # individual pages of a complex item from CONTENTdm. It is only on search results
      # where we really need the benefit of fast thumbnails and IIIF will supply them
      # on the show views. DOC_IDS may include child doc ids if you want.
      response = ENV['DOC_IDS'].present? ? query.scoped(ENV.fetch('DOC_IDS', nil)) : query.all_primary

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

      # Though it is likely only primary doc thumbs were stored, this will purge ALL of them
      # including any one-off child doc thumbs that may have been collected.
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
