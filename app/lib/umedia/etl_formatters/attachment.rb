# frozen_string_literal: true

module Umedia
  # Extraction, Transformation, Loading Field data formatters
  module EtlFormatters
    # Attachments appear below the main view area as supplemental objects.
    # This class figures out what kind of object should be displayed.
    class Attachment
      attr_reader :record, :filename

      def initialize(record: {})
        @record = record
        @filename = record.fetch('find', '')
      end

      def format
        return unless attachable? && filename.respond_to?(:split)

        case filename.split('.').last
        when 'pdf'
          'pdf'
        when 'jp2'
          'iiif'
        end
      end

      private

      # Only Kaltura or parents that have explicitly designated a child
      # as an attachment can display an attachment
      def attachable?
        kaltura? || attached_child?
      end

      # Only Child records can be an attachment if the item is not kaltura
      # The child ID must match the attach id set in the parent record
      def attached_child?
        return false unless record['record_type'] == 'secondary'

        id == attached_child_id
      end

      def attached_child_id
        record.fetch('parent', {}).fetch('attach', :ATTACHMENT)
      end

      def id
        record['id']
      end

      # All kaltura items have attachments
      # These are non-compound records with a single attachment
      def kaltura?
        !%w[kaltur kaltua kaltub kaltuc kaltud]
          .reject { |k| record.fetch(k, {}) == {} }.empty?
      end
    end
  end
end
