# frozen_string_literal: true

require 'titleize'
require 'json'
require 'net/http'

# Formatters to clean up CONTENTdm API metadata
module Umedia
  class Formatters
    # @TODO
    # - Move generic formatters to CDMDEXER
    # - Only keep UofMN specific formatters here

    # ObjectFormatter
    class ObjectFormatter
      def self.format(value)
        collection, id = value.split(':')
        "https://cdm16022.contentdm.oclc.org/utils/getthumbnail/collection/#{collection}/id/#{id}"
      end
    end

    # SuperCollectionNamesFormatter
    class SuperCollectionNamesFormatter
      def self.format(value)
        names = value.fetch('projea', '')
        return unless names.respond_to?(:split)

        names.split(';').map do |set_spec|
          value['oai_sets'].fetch(set_spec, {})
                           .fetch(:name, '')
                           .gsub(/^ul_([a-zA-Z0-9])*\s-\s/, '')
        end
      end
    end

    # SuperCollectionDescriptionsFormatter
    class SuperCollectionDescriptionsFormatter
      def self.format(value)
        names = value.fetch('projea', '')
        return unless names.respond_to?(:split)

        names.split(';').map do |set_spec|
          value['oai_sets'].fetch(set_spec, {})
                           .fetch(:description, '')
        end
      end
    end

    # NumberSortFormatter
    class NumberSortFormatter
      def self.format(val)
        # Ah, library metadata; strip off the fake ranges
        val = val.gsub(/^- /, '')
        val.split('-').first.gsub(/([^0-9|\s]*)/i, '')
      end
    end

    # ToSolrDateFormatter
    class ToSolrDateFormatter
      def self.format(date)
        "#{date}T00:00:00Z"
      end
    end

    # LetterSortFormatter
    class LetterSortFormatter
      def self.format(value)
        value.gsub(/([^a-z|0-9]*)/i, '').downcase
      end
    end

    # FormatNameFormatter
    class FormatNameFormatter
      def self.format(value)
        value.split(';').map { |val| val.split('|').first }
      end
    end

    # SubjectFormatter
    class SubjectFormatter
      def self.format(subjects)
        # Try to rip out periods from non-names
        # e.g.
        # African Americans. -> African Americans
        # Newton, W. H. -> Newton, W. H.
        # Only mace if we have more than one letter prior to a trailing period
        subjects.map do |subject|
          if subject =~ /[a-z]{2,}\.$/i
            subject.gsub(/\./, '')
          else
            subject
          end
        end
      end
    end

    # SemiSplitFirstFormatter
    class SemiSplitFirstFormatter
      def self.format(value)
        value.split(';').first
      end
    end

    # PageCountFormatter
    class PageCountFormatter
      def self.format(values)
        if values['page'].respond_to?(:length)
          values['page'].length
        else
          1
        end
      end
    end

    # DocumentFormatter
    class DocumentFormatter
      def self.format(_id)
        'item'
      end
    end

    # FirstViewerTypeFormatter
    class FirstViewerTypeFormatter
      def self.format(record)
        first_page = record['first_page']
        if first_page
          Umedia::ViewerMap.new(record: first_page).viewer
        else
          Umedia::ViewerMap.new(record: record).viewer
        end
      end
    end

    # ViewerTypeFormatter
    class ViewerTypeFormatter
      def self.format(value)
        Umedia::ViewerMap.new(record: value).viewer
      end
    end

    # AttachmentFormatter
    class AttachmentFormatter
      def self.format(record)
        Umedia::EtlFormatters::Attachment.new(record: record).format
      end
    end

    # FeaturedCollectionOrderFormatter
    class FeaturedCollectionOrderFormatter
      def self.format(doc)
        order = doc.fetch('featur', false)
        order.presence || 999
      end
    end
  end
end
