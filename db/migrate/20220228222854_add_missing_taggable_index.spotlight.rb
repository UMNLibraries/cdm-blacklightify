# frozen_string_literal: true

# This migration comes from spotlight (originally 20150410180015)
# This migration comes from acts_as_taggable_on_engine (originally 4)
class AddMissingTaggableIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :taggings, %i[taggable_id taggable_type context]
  end

  def self.down
    remove_index :taggings, %i[taggable_id taggable_type context]
  end
end
