class AddDiscoveryEnabledToSpotlightExhibits < ActiveRecord::Migration[7.2]
  def change
    add_column :spotlight_exhibits, :discovery_enabled, :boolean, default: true
  end
end
