require 'sidekiq'

# Delete a batch of thumbnails
class TranscriptsIndexerWorker
  include Sidekiq::Worker

  attr_writer :indexer_klass
  attr_reader :page, :set_spec, :after_date
  def perform(page = 1, set_spec = false, after_date = false)
    @page = page
    @set_spec = set_spec
    @after_date = after_date
    indexer.index!
    unless indexer.empty?
      TranscriptsIndexerWorker.perform_async(indexer.next_page, set_spec, after_date)
    end
  end

  def indexer_klass
    @indexer_klass ||= Umedia::IndexTranscripts
  end

  def indexer
    @indexer ||= indexer_klass.new(set_spec: set_spec, page: page, after_date: after_date)
  end
end
