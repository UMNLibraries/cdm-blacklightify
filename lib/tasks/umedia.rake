# frozen_string_literal: true

require 'bundler/audit/task'
Bundler::Audit::Task.new

task default: 'bundle:audit'

desc 'Run test suite'
task ci: :environment do
  success = true
  system('RAILS_ENV=test bundle exec rails test:system test') || success = false
  system('bundle exec rake bundle:audit') || success = false
  exit!(1) unless success
end
