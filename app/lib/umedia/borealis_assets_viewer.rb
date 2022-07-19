# frozen_string_literal: true

module Umedia
  class BorealisAssetsViewer
    attr_reader :assets

    def initialize(assets: [])
      @assets = [assets].flatten
    end

    def asset
      assets.first
    end
  end
end
