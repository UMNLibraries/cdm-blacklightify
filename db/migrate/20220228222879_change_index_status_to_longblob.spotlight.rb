# frozen_string_literal: true

# This migration comes from spotlight (originally 20170821165811)
class ChangeIndexStatusToLongblob < ActiveRecord::Migration[5.0]
  def change
    change_column :spotlight_solr_document_sidecars, :index_status, :binary, limit: 10.megabytes
  end
end
