# frozen_string_literal: true

# This migration comes from spotlight (originally 20141117111311)
class CreateLocks < ActiveRecord::Migration[4.2]
  def change
    create_table :spotlight_locks do |t|
      t.references :on, polymorphic: true
      t.references :by, polymorphic: true
      t.timestamps
    end

    add_index :spotlight_locks, %i[on_id on_type], unique: true
  end
end
