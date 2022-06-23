# frozen_string_literal: true

# This is a document extension meant to be mixed into a
# Blacklight::Solr::Document class, such as SolrDocument. It provides support
# for creating bibtex format from a Solr document.
#
# This extension would normally be registered using
# Blacklight::Solr::Document#use_extension.  eg:
#
# SolrDocument.use_extension( Blacklight::Document::BibTeX )
#
# This extension also expects some data from blacklight_config (set in Catalog Controller)

require 'bibtex'

module Blacklight
  module Document
    module Bibtex
      def self.extended(document)
        Blacklight::Document::Bibtex.register_export_formats(document)
      end

      def self.register_export_formats(document)
        document.will_export_as(:bibtex, 'application/x-bibtex')
      end

      def export_as_bibtex
        config = ::CatalogController.blacklight_config.citeproc

        entry = ::BibTeX::Entry.new
        entry.type = :misc
        entry.key = id
        entry.title = first config[:fields][:title]
        multiple_valued_fields = %i[author editor]

        # @TODO: Braces make these values string literals
        multiple_valued_fields.each do |field|
          entry.send("#{field}=", '{' + fetch(config[:fields][field]).join('') + '}') if has? config[:fields][field]
        end

        single_valued_fields = %i[address annote booktitle chapter doi edition how_published institution
                                  journal key month note number organization pages publisher school series url volume year]
        single_valued_fields.each do |field|
          entry.send("#{field}=", first(config[:fields][field])) if has? config[:fields][field]
        end

        # @TODO: Need to write via field values
        entry.send("url=", "#{Rails.application.routes.url_helpers.solr_document_url(self, { host: Rails.application.config.action_mailer.default_url_options[:host] } )}")

        # @TODO: Note does not render?
        entry.send("urldate=", Date.today)

        entry
      end

      private

      def bibtex_type(config)
        config[:format][:mappings].each do |bibtex, solr|
          return bibtex if solr.include? first config[:format][:field]
        end
        config[:format][:default_format] || :misc
      end
    end
  end
end
