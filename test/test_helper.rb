# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  # minimum_coverage 100
end

ENV['RAILS_ENV'] ||= 'test'
require 'minitest/autorun'

require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
