# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'
require 'json'

Spotlight::Exhibit.destroy_all
Spotlight::BlacklightConfiguration.destroy_all
Spotlight::FeaturedImage.destroy_all
Spotlight::Search.destroy_all

# 01 EXHIBITS
CSV.foreach('db/seeds/seed_spotlight_exhibits.csv', headers: true) do |row|
  Spotlight::Exhibit.create(row.to_h)
end

# 02 exhibit CONFIGURATIONS
CSV.foreach('db/seeds/seed_spotlight_blacklight_configurations.csv', headers: true) do |row|
  Spotlight::BlacklightConfiguration.find_or_create_by(row.to_h)
end

# 03 thumbnail FEATURED IMAGES
Spotlight::FeaturedImage.destroy_all
CSV.foreach('db/seeds/seed_spotlight_featured_images.csv', headers: true, liberal_parsing: true) do |row|
  Spotlight::FeaturedImage.insert(row.to_h)
end

# 04 update FILTERS created during exhibit creation
CSV.foreach('db/seeds/seed_spotlight_filters.csv', headers: true) do |row|
  filter = Spotlight::Filter.find_or_create_by(exhibit_id: row['exhibit_id'])
  filter.update(
    field: row['field'],
    value: row['value']
  )
end

# 05 SEARCHES (exhibit must be present to create a search). refactor this at some point . . .
CSV.foreach('db/seeds/seed_spotlight_searches.csv', headers: true, liberal_parsing: true) do |row|
  Spotlight::Search.find_or_create_by(
    title: row['title'],
    slug: row['slug'],
    long_description: row['long_description'],
    query_params: JSON.parse(row['query_params']),
    weight: row['weight'],
    published: row['published'],
    exhibit_id: row['exhibit_id'],
    default_index_view_type: row['default_index_view_type'],
    search_box: row['search_box'],
  )
end

# 06 PAGES
CSV.foreach('db/seeds/seed_spotlight_pages.csv', headers: true) do |row|
  filter = Spotlight::Page.find_or_create_by(exhibit_id: row['exhibit_id'])
  filter.update(
    content: row['content'],
    display_sidebar: row['display_sidebar']
  )
end

#07 TAGS & TAGGINGS
CSV.foreach('db/seeds/seed_tags.csv', headers: true, liberal_parsing: true) do |row|
  ActsAsTaggableOn::Tag.find_or_create_by(
    id: row['id'],
    name: row['name']
  )
end

CSV.foreach('db/seeds/seed_taggings.csv', headers: true, liberal_parsing: true) do |row|
  ActsAsTaggableOn::Tagging.find_or_create_by(
    tag_id: row['tag_id'],
    taggable_id: row['taggable_id'],
    taggable_type: row['taggable_type'],
    context: row['context']
  )
end