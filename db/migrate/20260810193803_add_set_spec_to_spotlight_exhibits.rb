class AddSetSpecToSpotlightExhibits < ActiveRecord::Migration[6.1]
  def change
    add_column :spotlight_exhibits, :set_spec, :string, unique: true
  end

  def down
    remove_column :spotlight_exhibits, :set_spec
  end
end
