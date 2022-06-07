module Umedia
  class CiteCitation
    attr_reader :solr_doc, :base_url
    def initialize(solr_doc: '{}', base_url: '')
      @solr_doc = solr_doc
      @base_url = base_url
    end

    def to_hash
      {
        focus: false,
        type: 'citation',
        label: 'Citation',
        fields: fields
      }
    end

    def fields
      {
        mappings: [{}],
        field_values:
          {
            creator: solr_doc['creator_ssim'],
            ref_name: 'University of Minnesota',
            creation_date: solr_doc['dat_ssi'],
            title: solr_doc['title_ssi'],
            type: solr_doc['type_ssi'],
            description: solr_doc['description_ts'],
            subject: solr_doc['subject_ssim'],
            contributing_organization: solr_doc['contributing_organization_ssi'],
            url: "#{base_url}/catalog/#{solr_doc['id']}",
            current_date: Time.now
          }
      }
    end
  end
end
