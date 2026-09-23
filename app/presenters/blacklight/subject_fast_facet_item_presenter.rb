module Blacklight
  # Custom facet item presenter for subject_fast_ssim that displays FAST labels
  class SubjectFastFacetItemPresenter < Blacklight::FacetItemPresenter
    def label
      # facet_item can be either an object with .value or a plain String
      uri_value = if facet_item.respond_to?(:value)
                    facet_item.value
                  else
                    facet_item.to_s
                  end
      
      # Try to get the FAST label from the URI value
      begin
        label = OclcSubjectFastService.new(uri_value).fast_data
        label.presence || uri_value
      rescue => e
        Rails.logger.warn("SubjectFastFacetItemPresenter error for #{uri_value}: #{e.message}")
        uri_value
      end
    end
  end
end
