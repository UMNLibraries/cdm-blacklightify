# frozen_string_literal: true

module CDMDEXER
  # Callback for job completion
  class CompletedCallback
    def self.call!(config)
      # e.g. commit records  - ::SolrClient.new.commit
      Rails.logger.info "Processing last batch for: #{config['set_spec']}"
    end
  end

  # Callback for cdmdexer OAI request notification
  class OaiNotification
    def self.call!(location)
      Rails.logger.info "CDMDEXER: Requesting OAI: #{location}"
    end
  end

  # Callback for cdmdexer indexer request notifications
  class CdmNotification
    def self.call!(collection, id, _endpoint)
      Rails.logger.info "CDMDEXER: Requesting: #{collection}:#{id}"
    end
  end

  # Callback for cdmdexer Loader job starting
  class LoaderNotification
    def self.call!(ingestables, deletables)
      Rails.logger.info "CDMDEXER: Loading #{ingestables.length} records and deleting #{deletables.length}"
    end
  end

  # Callback for CONTENTdm errors
  class CdmError
    def self.call!(error)
      Rails.logger.info "CDMDEXER: #{error}"
      # e.g. push error to a slack channel or send an email alert
    end
  end
end
