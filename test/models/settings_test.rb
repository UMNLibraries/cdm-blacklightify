# frozen_string_literal: true

require 'test_helper'

class SettingsTest < ActiveSupport::TestCase
  test 'basic attributes are set' do
    assert Settings.fields
    assert Settings.field_mappings
  end

  test 'UMedia Solr field_mappings are present' do
    # @TODO: expand as necessary
    fields = %w[id object_ssi setspec_ssi]
    mappings = Settings.field_mappings.collect(&:dest_path)
    fields.each { |field| assert_includes mappings, field }
  end
end
