# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Umedia
  # Application
  class Application < Rails::Application
    config.action_mailer.default_url_options = { host: 'localhost:3000', from: 'noreply@example.com' }
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol, Struct]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"

    config.eager_load_paths += Dir[Rails.root.join(File.join('app', 'lib', '**', '**.rb'))]

    # Background Jobs
    config.active_job.queue_adapter = :sidekiq
  end
end
