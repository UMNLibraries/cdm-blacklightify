# Basic solr connection config and solr conveniences
class SolrClient
  attr_reader :url, :solr_klass
  def initialize(url: ENV['SOLR_URL'], solr_klass: RSolr)
    @url = url
    @solr_klass = solr_klass
  end

  def solr
    @solr ||= solr_klass.connect url: url
  end

  def delete_index
    solr.delete_by_query '*:*'
    solr.commit
  end

  def commit
    solr.commit
  end

  def optimize
    solr.optimize
  end

  def add(records)
    solr.add records
  end

  def backup(number_to_keep: 1, backup_name: nil)
    solr.get 'replication', params: {
      command: 'backup',
      location: ENV['SOLR_BACKUP_LOCATION'],
      name: backup_name,
      numberToKeep: number_to_keep
    }
  end

  def restore(backup_name: nil)
    solr.get 'replication', params: {
      command: 'restore',
      location: ENV['SOLR_BACKUP_LOCATION'],
      name: backup_name
    }
  end
end
