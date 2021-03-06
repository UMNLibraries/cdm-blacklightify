# frozen_string_literal: true

# This migration comes from spotlight (originally 20140211212626)
class CreateSpotlightSolrDocumentSidecars < ActiveRecord::Migration[4.2]
  def change
    create_table :spotlight_solr_document_sidecars do |t|
      t.references :exhibit, index: true
      t.string :solr_document_id, index: true
      t.boolean :public, default: true
      t.text :data

      t.timestamps
    end
  end
end
