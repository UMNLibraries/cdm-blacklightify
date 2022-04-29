# Original from http://snippets.dzone.com/posts/show/4468 by MichaelBoutros
#
# Optimized version which uses to_yaml for content creation and checks
# that models are ActiveRecord::Base models before trying to fetch
# them from database.
namespace :db do
  namespace :fixtures do
    desc 'Dumps all models into fixtures.'
    task :dump => :environment do
      models = %w(Spotlight::BlacklightConfiguration Spotlight::Site Spotlight::Search Spotlight::Page Spotlight::Filter Spotlight::FeaturedImage Spotlight::Exhibit Spotlight::MainNavigation FriendlyId::Slug)

      # excludes models
      excludes = %w(ApplicationRecord)

      puts "Found models: " + models.join(', ')

      models.reject{|m| m.in?(excludes)}.each do |m|
        model = m.constantize
        next unless model.ancestors.include?(ActiveRecord::Base)

        puts "Dumping model: " + m
        entries = model.order(id: :asc).all

        increment = 1

        model_file = "#{Rails.root}/test/fixtures/#{m.underscore.pluralize}.yml"
        File.open(model_file, 'w') do |f|
          entries.each do |a|
            attrs = a.attributes
            attrs.delete_if{|k,v| v.blank?}

            output = {m + '_' + increment.to_s => attrs}
            f << output.to_yaml.gsub(/^--- \n/,'') + "\n"

            increment += 1
          end
        end
      end
    end
  end
end
