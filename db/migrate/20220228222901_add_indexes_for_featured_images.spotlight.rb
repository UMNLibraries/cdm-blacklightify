# frozen_string_literal: true

# This migration comes from spotlight (originally 20210506070809)
class AddIndexesForFeaturedImages < ActiveRecord::Migration[5.2]
  def change
    add_index(:spotlight_searches, [:thumbnail_id])
    add_index(:spotlight_searches, [:masthead_id])
    add_index(:spotlight_exhibits, [:thumbnail_id])
    add_index(:spotlight_exhibits, [:masthead_id])
    add_index(:spotlight_pages, [:thumbnail_id])
  end
end
