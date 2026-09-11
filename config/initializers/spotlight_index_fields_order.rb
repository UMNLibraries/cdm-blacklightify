# frozen_string_literal: true

##
# SPOTLIGHT INDEX FIELD ORDERING
#
# PURPOSE:
# Ensures that Spotlight exhibits render search results (index/browse pages) with the
# same field order and selection as the default CatalogController configuration.
#
# PROBLEM SOLVED:
# Spotlight's configuration merges exhibit-specific fields with default fields,
# causing index fields to be reordered and many additional fields to be included.
# Title appears last instead of first in Spotlight browse search results.
#
# SOLUTION:
# Patch Spotlight::Engine configuration to ensure index fields are preserved
# in the correct order when the exhibit's blacklight_config is built.
#
# FIELDS PRESERVED (in order):
# 1. title
# 2. collection_name
# 3. date_created
# 4. format_name
# 5. description
# 6. subject_ssm
# 7. subject_fast_ssim
#

Rails.application.config.to_prepare do
  # Define the standard index fields in display order
  UMEDIA_INDEX_FIELDS_ORDER = %w[
    title
    collection_name
    date_created
    format_name
    description
    subject_ssm
    subject_fast_ssim
  ].freeze

  # Patch the Blacklight::Configuration to sort index fields in our defined order
  # This hooks into the configuration building process for Spotlight searches
  module UmediaIndexFieldOrdering
    # Override the index_fields accessor to return fields in our desired order
    def index_fields
      fields = super
      return fields unless fields.is_a?(Hash) && fields.any?
      
      # Build a new hash with fields sorted in UMEDIA_INDEX_FIELDS_ORDER
      ordered = {}
      UMEDIA_INDEX_FIELDS_ORDER.each do |field_name|
        ordered[field_name] = fields[field_name] if fields.key?(field_name)
      end
      
      # Add any remaining fields not in our list (shouldn't happen but be safe)
      fields.each do |name, config|
        ordered[name] = config unless ordered.key?(name)
      end
      
      ordered
    end
  end

  # Patch Blacklight::Configuration to use our ordering
  Blacklight::Configuration.prepend(UmediaIndexFieldOrdering) unless Blacklight::Configuration.ancestors.include?(UmediaIndexFieldOrdering)
end
