# frozen_string_literal: true

module Blacklight
  class SearchButtonComponent < Blacklight::Component
    def initialize(text:, id:)
      @text = text
      @id = id
    end

    def call
      tag.button(class: 'btn btn-primary search-btn', type: 'submit', id: @id) do
        # removed "submit-search-text" to reveal the Search text on form button . . . 
        tag.span(@text, class: "") +
          render(Blacklight::Icons::SearchComponent.new)
      end
    end
  end
end
