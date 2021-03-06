# frozen_string_literal: true

# This migration comes from spotlight (originally 20180822233601)
class ChangeTypeOfTaggingsTaggable < ActiveRecord::Migration[5.1]
  def change
    change_column :taggings,
                  :taggable_id,
                  :integer,
                  using: 'taggable_id::integer'
  end
end
