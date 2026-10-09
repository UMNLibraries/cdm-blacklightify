# frozen_string_literal: true

module Blacklight
  module Document
    # Override of Blacklight's ActionComponent to extract document ID before building URLs
    class ActionComponent < Blacklight::Component
      with_collection_parameter :action

      # @param [Blacklight::Document] document
      def initialize(document:, action:, options: {}, url_opts: {}, id: nil, link_classes: 'nav-link')
        @document = document
        @action = action
        @options = options
        @url_opts = url_opts
        @id = id || @action.fetch(:id, "#{@action.name}Link")
        @link_classes = link_classes
      end

      def render_control
        return link_to_modal_control if using_default_document_action?

        render_partial
      end

      def using_default_document_action?
        @action.component || @action.partial == 'document_action'
      end

      def link_to_modal_control
        link_to label,
                url,
                id: @id,
                class: @link_classes,
                data: {}.merge(({ blacklight_modal: "trigger", turbo: false } if @action.modal != false) || {})
      end

      def render_partial
        render(partial: @action.partial || @action.name.to_s,
               locals: { document: @document, document_action_config: @action }.merge(@options))
      end

      def label
        t("blacklight.tools.#{@action.name}", default: @action.label || @action.name.to_s.humanize)
      end

      # Action buttons get their URLs in one of three ways:
      # - the action configuration explicitly specifies a helper method to call
      # - a url route is inferred for ActiveModel-compliant objects (the default;
      #     note that, although Rails routing is available here, we still call out to
      #     helpers regardless, because that's where applications might have overridden the
      #     default Rails routing behavior)
      # - calling out to an implicit helper method with a conventional name (unlikely)
      def url
        # Extract document ID instead of passing the full object
        doc_id = if @document.respond_to?(:id)
                   @document.id
                 else
                   @document.to_s
                 end

        url_opts = @url_opts.merge(({ id: doc_id } if @document) || {})
        if @action.path
          helpers.public_send(@action.path, url_opts)
        elsif url_opts[:id].class.respond_to?(:model_name)
          helpers.url_for([@action.key.to_sym, url_opts[:id]])
        else
          route_helper = "#{@action.key}_#{helpers.controller_name}_path"
          # Check if the route helper exists before calling it
          if helpers.respond_to?(route_helper)
            helpers.public_send(route_helper, url_opts)
          else
            # Fallback: try without the controller name
            fallback_helper = "#{@action.key}_path"
            helpers.public_send(fallback_helper, url_opts) if helpers.respond_to?(fallback_helper)
          end
        end
      end

      delegate :key, to: :@action
    end
  end
end
