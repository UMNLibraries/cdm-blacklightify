# frozen_string_literal: true

Config.setup do |config|
  config.const_name = 'Settings'
end

# Prepend CDMDEXER config gem settings
Settings.prepend_source!(File.expand_path('cdmdexer.yml', __dir__))
Settings.reload!
