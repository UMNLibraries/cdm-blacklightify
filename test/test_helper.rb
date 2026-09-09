# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'minitest/autorun'

SimpleCov.start 'rails' do
  # minimum_coverage 100
end

require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'

Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    parallelize(workers: 1)
    fixtures :all
  end
end
