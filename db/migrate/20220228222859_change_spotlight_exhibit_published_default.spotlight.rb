# frozen_string_literal: true

# This migration comes from spotlight (originally 20151117153210)
class ChangeSpotlightExhibitPublishedDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :spotlight_exhibits, :published, :boolean, default: false
  end
end
