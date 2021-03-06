# frozen_string_literal: true

# This migration comes from spotlight (originally 20190910200927)
class CreateSpotlightCustomSearchFields < ActiveRecord::Migration[5.1]
  def change
    create_table :spotlight_custom_search_fields do |t|
      t.string :slug
      t.string :field
      t.text :configuration
      t.references :exhibit

      t.timestamps
    end
  end
end
