# frozen_string_literal: true

# This migration comes from spotlight (originally 20160929180534)
class AddDocumentIndexToSolrDocumentSidecar < ActiveRecord::Migration[4.2]
  def change
    add_index :spotlight_solr_document_sidecars, %i[exhibit_id document_type document_id],
              name: 'spotlight_solr_document_sidecars_exhibit_document'
    add_index :spotlight_solr_document_sidecars, %i[document_type document_id],
              name: 'spotlight_solr_document_sidecars_solr_document'
  end
end
