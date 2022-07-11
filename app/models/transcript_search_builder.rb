# frozen_string_literal: true

# TranscriptSearchBuilder
class TranscriptSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Spotlight::SearchBuilder

  self.default_processor_chain += [:scope_to_parent]

  def scope_to_parent(solr_parameters)
    solr_parameters[:rows] = blacklight_params[:rows] || 1000
    solr_parameters[:fq] = "parent_id_ssi:\"#{blacklight_params[:id]}\""
    solr_parameters[:sort] = 'title_sort_ssortsi asc'
  end
end
