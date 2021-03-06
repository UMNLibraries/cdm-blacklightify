# frozen_string_literal: true

# This migration comes from spotlight (originally 20180405044000)
class AddLocaleToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_pages, :locale, :string, default: I18n.default_locale
    add_index :spotlight_pages, :locale
  end
end
