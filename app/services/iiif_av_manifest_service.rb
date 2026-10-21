class IiifAvManifestService
  include KalturaHelper

  PRESENTATION_CONTEXT = 'http://iiif.io/api/presentation/3/context.json'.freeze

  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def av_manifest
    manifest
  end

  private

  def manifest
    {
      '@context' => PRESENTATION_CONTEXT,
      'id' => manifest_id,
      'type' => 'Manifest',
      'label' => language_map(@document[:title]),
      'metadata' => metadata.compact,
      'requiredStatement' => required_statement,
      'items' => canvases
    }.tap do |hsh|
      hsh['rights'] = @document[:rights_statement_uri] if @document[:rights_statement_uri].present?
    end
  end

  def metadata
    # this just mimics what contentdm produces
    meta = [{
      :label => 'Parent Collection Name',
      :value => @document[:parent_collection]
    },
    {
      :label => 'Additional Notes',
      :value => @document[:notes]
    },
    {
      :label => 'Contact Information',
      :value => @document[:contact_information]
    },
    {
      :label => 'Continent',
      :value => @document[:Continent]
    },
    {
      :label => 'Contributing Organization',
      :value => @document[:contributing_organization]
    },
    {
      :label => 'Contributor',
      :value => @document[:contributor]
    },
    {
      :label => 'Country',
      :value => @document[:country]
    },
    {
      :label => 'Date of Creation',
      :value => @document[:date_created]
    },
    {
      :label => 'Description',
      :value => @document[:description]
    },
    {
      :label => 'Dimensions',
      :value => duration_to_float
    },
    {
      :label => 'DLS Identifier',
      :value => @document[:description]
    },
    {
      :label => 'Fiscal Sponsor',
      :value => @document[:fiscal_sponsor]
    },
    {
      :label => 'Item Physical Format',
      :value => @document[:format]
    },
    {
      :label => 'Historical Era/Period',
      :value => @document[:historical_era]
    },
    {
      :label => 'Language',
      :value => @document[:language]
    },
    {
      :label => 'Local Rights Statement',
      :value => @document[:local_rights]
    },
    {
      :label => 'Persistent URL (PURL)',
      :value => @document[:persistent_url]
    },
    {
      :label => 'Publisher',
      :value => @document[:publisher]
    },
    {
      :label => 'Locally Assigned Subject Headings',
      :value => @document[:subject]
    },
    {
      :label => 'Title',
      :value => @document[:title]
    },
    {
      :label => 'Item Type',
      :value => @document[:types]
    }]

    meta.map do |field|
      next if field[:value].blank?

      {
        'label' => language_map(field[:label]),
        'value' => language_map(field[:value])
      }
    end
  end

  def required_statement
    {
      'label' => language_map('Attribution'),
      'value' => language_map(@document[:local_rights].presence || rights_statement)
    }
  end

  def rights_statement
    "The University of Minnesota believes that this item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s). #{@document[:rights_statement_uri]}"
  end

  def duration_to_float
    @document[:dimensions] ? Time.parse(@document[:dimensions]).seconds_since_midnight : nil
  end

  def field_selector
    @document[:kaltura_audio] ? @document[:kaltura_audio] : @document[:kaltura_video]
  end

  def manifest_id
    "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/av/manifest.json"
  end

  def media_type
    @document[:kaltura_audio] ? 'Sound' : 'Video'
  end

  def media_format
    @document[:kaltura_audio] ? 'audio/mp4' : 'video/mp4'
  end

  def language_map(value)
    values = Array.wrap(value).flatten.compact.map(&:to_s).map(&:strip).reject(&:blank?)
    return nil if values.empty?

    { 'en' => values }
  end

  def canvases
    arr = field_selector.to_s.split(';').map(&:strip).reject(&:blank?)

    arr.map.with_index do |asset, index|
      canvas_id = "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/canvas/c#{index}"
      annotation_id = "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/annotation/a#{index}"
      {
        'id' => canvas_id,
        'type' => 'Canvas',
        'label' => language_map(@document[:title]),
        'duration' => duration_to_float,
        'items' => [{
          'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/page/p#{index}",
          'type' => 'AnnotationPage',
          'items' => [{
            'id' => annotation_id,
            'type' => 'Annotation',
            'motivation' => 'painting',
            'body' => {
              'id' => @document[:kaltura_audio] ? kaltura_audio_playmanifest_url(asset) : kaltura_video_playmanifest_url(asset),
              'type' => media_type,
              'format' => media_format,
              'duration' => duration_to_float
            }.compact,
            'target' => canvas_id
          }]
        }]
      }.compact
    end
  end
end
