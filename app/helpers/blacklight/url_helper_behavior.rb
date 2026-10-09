# frozen_string_literal: true

module Blacklight
  module UrlHelperBehavior
    # Override to extract document ID before calling search_state.url_for_document
    def link_to_document(doc, field_or_opts = nil, opts = { counter: nil })
      label = case field_or_opts
              when NilClass
                document_presenter(doc).heading
              when Hash
                opts = field_or_opts
                document_presenter(doc).heading
              else # String
                field_or_opts
              end

      # Extract document ID if doc is an object
      doc_id = doc.respond_to?(:id) ? doc.id : doc
      
      link_to label, search_state.url_for_document(doc_id), session_tracking_params(doc_id, opts[:counter]).deep_merge(opts.except(:label, :counter))
    end
  end
end

