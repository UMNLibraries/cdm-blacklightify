# frozen_string_literal: true

# This migration comes from spotlight (originally 20150127173245)
class AddFeaturedImageToExhibit < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_exhibits, :featured_image, :string
  end
end
