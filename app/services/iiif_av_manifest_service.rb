class IiifAvManifestService

  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def manifest2
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
    [ '', @document[:local_rights] ]
  end

  def duration_to_float
    @document[:dimensions] ? Time.parse(@document[:dimensions]).seconds_since_midnight : ''
  end

  def field_selector
    @document[:kaltura_audio] ? @document[:kaltura_audio] : @document[:kaltura_video]
  end

  def type_selector
    @document[:kaltura_audio] ? 
      # audio
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_audio] + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4' : 
      # video
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_video] + '/flavorId/1_uivmmxof/format/url/protocol/http/a.mp4'
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
              'id' => 'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + asset.strip + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4',
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
