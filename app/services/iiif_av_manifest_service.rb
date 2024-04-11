class IiifAvManifestService
  # attr_reader :id

  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def manifest2
    get_manifest_call
  end

  private

  def get_manifest_call
    # calling the method to json
    manifest.to_json
  end

  def manifest
    # hashing the data . . . video as the current example resource item
    {
      'context': 'http://iiif.io/api/presentation/2/context.json',
      '@id' => @document[:object], 
      '@type' => 'sc:Manifest',
      'label' => @document[:title], 
      'metadata' => metadata,
      'attribution' => attribution,
      'sequences' => [{
        '@id' => 'http://PLACEHOLDER.com/manifest/seq/',
        '@type': 'sc:Sequence',
        'canvases' => [{
          '@id' => 'http://PLACEHOLDER.com/canvas',
          '@type' => 'sc:Canvas' ,
          'label' => @document[:title],
          'items' => [{
            'id' => 'https://iiif.io/api/PLACEHOLDER/canvas/page',
            'type' => 'AnnotationPage',
            'items' => [{
              'id' => 'https://iiif.io/api/PLACEHOLDER/page/annotation',
              'type' => 'Annotation',
              'motivation' => 'painting',
              'body' => {
                'id' => type_selector,
                'type' => 'Video',
                'duration' => @document[:dimensions],
                'format' => 'video/mp4'
              }
            }]
          }]
        }]
      }]
    }
  end

  def metadata
    [{
      'label' => 'Parent Collection Name',
      'value' => @document[:parent_collection]
    },
    {
      'label' => 'Additional Notes',
      'value' => @document[:notes]
    },
    {
      'label' => 'Contact Information',
      'value' => @document[:contact_information]
    },
    {
      'label' => 'Continent',
      'value' => @document[:Continent]
    },
    {
      'label' => 'Contributing Organization',
      'value' => @document[:contributing_organization]
    },
    {
      'label' => 'Contributor',
      'value' => @document[:contributor]
    },
    {
      'label' => 'Country',
      'value' => @document[:country]
    },
    {
      'label' => 'Date of Creation',
      'value' => @document[:date_created]
    },
    {
      'label' => 'Description',
      'value' => @document[:description]
    },
    {
      'label' => 'Dimensions',
      'value' => @document[:dimensions]
    },
    {
      'label' => 'DLS Identifier',
      'value' => @document[:description]
    },
    {
      'label' => 'Fiscal Sponsor',
      'value' => @document[:fiscal_sponsor]
    },
    {
      'label' => 'Item Physical Format',
      'value' => @document[:format]
    },
    {
      'label' => 'Historical Era/Period',
      'value' => @document[:historical_era]
    },
    {
      'label' => 'Language',
      'value' => @document[:language]
    },
    {
      'label' => 'Local Rights Statement',
      'value' => @document[:local_rights]
    },
    {
      'label' => 'Persistent URL (PURL)',
      'value' => @document[:persistent_url]
    },
    {
      'label' => 'Publisher',
      'value' => @document[:publisher]
    },
    {
      'label' => 'Locally Assigned Subject Headings',
      'value' => @document[:subject]
    },
    {
      'label' => 'Title',
      'value' => @document[:title]
    },
    {
      'label' => 'Item Type',
      'value' => @document[:types]
    }]
  end

  def attribution
    [
      '',
      @document[:local_rights]
    ]
  end

  def sequences

  end

  def type_selector
    @document[:kaltura_audio] ? 
      # audio
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_audio] + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4' : 
      # video
      'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + @document[:kaltura_video] + '/flavorId/1_uivmmxof/format/url/protocol/http/a.mp4'
  end
end
