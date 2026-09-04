class IiifAvManifestService
  include KalturaHelper

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
      'context' => 'http://iiif.io/api/presentation/2/context.json',
      '@id' => @document[:object], 
      '@type' => 'sc:Manifest',
      'label' => @document[:title], 
      'metadata' => metadata.compact,
      'attribution' => attribution,
      'sequences' => [{
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/sequence/s0',
        '@type' => 'sc:Sequence',
        'canvases' => canvases
      }]
    }
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
      field[:value].blank? ? nil : field
   end
  end

  def attribution
    [ 
      '', @document[:local_rights] ? @document[:local_rights] : rights_statement
    ]
  end

  def rights_statement
    "The University of Minnesota believes that this item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s). #{@document[:rights_statement_uri]}"
  end

  def duration_to_float
    @document[:dimensions] ? Time.parse(@document[:dimensions]).seconds_since_midnight : ''
  end

  def field_selector
    @document[:kaltura_audio] ? @document[:kaltura_audio] : @document[:kaltura_video]
  end

  def type_selector
    @document[:kaltura_audio] ? 
      kaltura_audio_playmanifest_url(@document[:kaltura_audio]) : 
      kaltura_video_playmanifest_url(@document[:kaltura_video])
  end

  def canvases
    arr = field_selector.split(';')

    arr.map.with_index do |asset, index|
      {
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/canvas/c#{index}",
        '@type' => 'sc:Canvas' ,
        'label' => @document[:title],
        'items' => [{
          'id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/page/p#{index}",
          'type' => 'AnnotationPage',
          'items' => [{
            'id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/annotation/a#{index}",
            'type' => 'Annotation',
            'motivation' => 'painting',
            'body' => {
              'id' => @document[:kaltura_audio] ? kaltura_audio_playmanifest_url(asset) : kaltura_video_playmanifest_url(asset),
              'type' => 'video',
              'format' => 'video/mp4',
              'duration' => duration_to_float
            }
          }]
        }]
      }
    end
  end
end
