# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# Explicit Logger require for Rails 6.1 + Ruby 3.3 compatibility
require 'logger'
# require 'bootsnap/setup' # Disabled due to Ruby 3.3 + Rails 6.1 compatibility issue
