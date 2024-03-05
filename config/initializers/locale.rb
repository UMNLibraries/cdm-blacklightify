# frozen_string_literal: true

Rails.application.config.after_initialize do
  I18n.available_locales = [:en, :es]
end
