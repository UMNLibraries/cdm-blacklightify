# frozen_string_literal: true

# Patches must be applied after_initialize when all gems are loaded
Rails.application.config.after_initialize do
  # Add to_param to DocumentPresenter so it can be used in route helpers
  Blacklight::DocumentPresenter.class_eval do
    def to_param
      document.to_param
    end
  end

  # Override Spotlight SearchState to extract document ID in url_for_document
  if defined?(Spotlight::SearchState)
    Spotlight::SearchState.class_eval do
      def url_for_document(document, options = {})
        return super unless current_exhibit

        # Extract document ID instead of passing the object
        doc_id = if document.respond_to?(:id)
                   document.id
                 else
                   document.to_s
                 end
        
        [controller.spotlight, current_exhibit, doc_id]
      end
    end
  end
end







