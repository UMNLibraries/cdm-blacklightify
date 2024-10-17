# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 5.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'ruby-jq'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test, :publicdev do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # ONLY on local dev, not if running publicdev on a srver
  gem 'web-console', '>= 4.1.0'
end

group :publicdev, :production do
  # For puma with systemd integration
  gem 'sd_notify', '>= 0.1.0'
  gem 'listen', '~> 3.3'
end

group :development do
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

gem 'blacklight', ' ~> 7.0'
gem 'blacklight-spotlight', github: 'projectblacklight/spotlight', branch: 'v3.5.0.2'
# https://github.com/projectblacklight/blacklight_range_limit#configuration
gem 'blacklight_range_limit', '~> 7.0'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test, :publicdev do
  gem 'solr_wrapper', '~> 4.0'
end

gem 'blacklight-gallery', '~> 3.0'
gem 'blacklight-oembed', '~> 1.0'
gem 'bootstrap', '~> 4.0'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'devise_invitable'
gem 'friendly_id'
gem 'jquery-rails'
gem 'openseadragon', '>= 0.2.0'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sitemap_generator'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'uglifier', '>= 1.3.0'

# Test suite
group :test, :publicdev do
  gem 'bundler-audit'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'm', '~> 1.5.0'
  gem 'minitest'
  gem 'minitest-ci', '~> 3.4.0'
  gem 'minitest-reporters'
  gem 'rubocop', '~> 1.25', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-context'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

# ContentDM Harvesting/Indexing
gem 'config'
gem 'contentdm_api', github: 'UMNLibraries/contentdm_api'
gem 'cdmdexer', github: 'UMNLibraries/cdmdexer', branch: 'develop'
gem 'foreman', '~> 0.80'
# We cannot move to Sidekiq 7 as long as the ETLWorker and TransformWorker
# pass complex objects (including multiple FieldMapping classes) to Sidekiq worker perform() methods
gem 'sidekiq', '~> 6.0'
gem 'dotenv-rails'

# Cache thumbnails locally
gem 'mimemagic', '~> 0.4.3'
gem 'addressable', '~> 2.8'


gem "net-smtp", "~> 0.3.1"

gem "net-imap", "~> 0.2.3"
gem "net-pop", "~> 0.1.1"

# IIIF Manifests
gem 'rack-cors', :require => 'rack/cors'

# Citations
gem 'rinku'

# Kaltura
gem 'kaltura-client', '17.5.0'

gem 'rails-controller-testing'

gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-template', git: 'https://github.com/UMNLibraries/capistrano-template-ruby3'
gem 'capistrano-bundler'
#gem 'capistrano-maintenance'
gem 'capistrano-yarn'
