# frozen_string_literal: true

# This migration comes from spotlight (originally 20210305171150)
class CreateBulkUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :spotlight_bulk_updates do |t|
      t.string :file, null: false
      t.references :exhibit
      t.timestamps
    end
  end
end
