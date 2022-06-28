# frozen_string_literal: true
# # frozen_string_literal: true

# module Umedia
#   # Full record itation formatters
#   module Citation
#     require_dependency "#{Rails.root}/app/lib/umedia/citation/formatters"
#     module Styles
#       class SchemaThumbnailFormatter
#         def self.format(doc)
#           Umedia::Thumbnail.new(object_url: doc.field_object.value,
#             viewer_type: doc.field_child_viewer_types.value.first,
#             entry_id: doc.field_kaltura_video.value).url
#         end
#       end

#       class AboutFormatter
#         def self.format(doc)
#           [
#             doc.field_subject.value,
#             doc.field_subject_fast.value
#           ].flatten
#         end
#       end

#       class LocationFormatter
#         def self.format(doc)
#           [
#             doc.field_subject.value,
#             doc.field_subject_fast.value
#           ].flatten
#         end
#       end

#       class SchemaOrg
#         def self.schema_open
#           ['<script type="application/ld+json"> {'
#             '"@context": "http://schema.org"',
#             '"@type": "CretiveWork",'
#             '"isAccessibleForFree":true,'
#             '"provider":[{"@type":"Organization","name":"University of Minnesota Libraries"},'
#           ].join("\n")
#         end
#         def self.mappings
#           [
#             { name: 'id', value: self.schema_open, formatters: [] },
#             { name: 'contributing_institution', prefix: '"@type":"Organization","name":"', suffix: '"}]', formatters: []},
#             { name: 'id', prefix: '"@id":"', suffix: '"', formatters: [URLFormatter] },
#             { name: 'rights_statement_uri', prefix: '"license":"', suffix: '",', formatters: [] },
#             { name: 'title', prefix: '"name":"', suffix: '",', formatters: [] },
#             { name: 'creator', prefix: '"creator":"', suffix: '",', formatters: [Umedia::Citation::CommaJoinFormatter] },
#             { name: 'contributor', prefix: '"contributor":"', suffix: '",', formatters: [Umedia::Citation::CommaJoinFormatter] },
#             { name: 'publisher', prefix: '"publisher":"', suffix: '",', formatters: [] },
#             { name: 'date_created', prefix: '"dateCreated":"', suffix: '",', formatters: [] },
#             { name: 'historical_era', prefix: '"temporalCoverage":"', suffix: '",', formatters: [Umedia::Citation::CommaJoinFormatter] },
#             { name: 'format', prefix: '"genre":"', suffix: '",', formatters: [Umedia::Citation::ExtractFormats] },
#             { name: '/', prefix: '"about":"', suffix: '",', formatters: [AboutFormatter] },
#             { name: '/', prefix: '"contentLocation":"', suffix: '",', formatters: [LocationFormatter] },
#             { name: 'id', prefix: '"mainEntityOfPage":"', suffix: '"', formatters: [URLFormatter] },
#             { name: '/', prefix: '"thumbnailUrl":"', suffix: '"', formatters: [SchemaThumbnailFormatter] }
#           ]
#         end
#       end
#     end
#   end
# end
