# frozen_string_literal: true

# This migration comes from spotlight (originally 20160329215014)
class AddReadonlyToCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_custom_fields, :readonly_field, :boolean, default: false
  end
end
