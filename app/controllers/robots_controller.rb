# frozen_string_literal: true

# Basic robots.txt generator
class RobotsController < ApplicationController
  def robots
    respond_to :text
  end
end
