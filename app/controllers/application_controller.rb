# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller
  include Umedia::Localizable

  layout :determine_layout if respond_to? :layout
end
