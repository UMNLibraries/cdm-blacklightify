# frozen_string_literal: true

# This migration comes from spotlight (originally 20141205005902)
class AddLayoutOptionsToExhibit < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_exhibits, :searchable, :boolean, default: true
    add_column :spotlight_exhibits, :layout,     :string
  end
end
