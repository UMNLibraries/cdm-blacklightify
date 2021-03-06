# frozen_string_literal: true

# This migration comes from spotlight (originally 20131120172811)
class CreateSpotlightAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :spotlight_attachments do |t|
      t.string :name
      t.string :file
      t.string :uid
      t.references :exhibit

      t.timestamps
    end
  end
end
