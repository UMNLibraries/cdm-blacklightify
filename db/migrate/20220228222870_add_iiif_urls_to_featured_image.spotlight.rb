# frozen_string_literal: true

# This migration comes from spotlight (originally 20160714144125)
class AddIiifUrlsToFeaturedImage < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_featured_images, :iiif_region, :string
    add_column :spotlight_featured_images, :iiif_manifest_url, :string
    add_column :spotlight_featured_images, :iiif_canvas_id, :string
    add_column :spotlight_featured_images, :iiif_image_id, :string
    add_column :spotlight_featured_images, :iiif_tilesource, :string
  end
end
