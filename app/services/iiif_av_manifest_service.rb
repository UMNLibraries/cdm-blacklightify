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
    # hashing the data . . . video as the current example resource item
    {
      'context': 'http://iiif.io/api/presentation/2/context.json',
      '@id' => @document[:object], 
      '@type' => 'sc:Manifest',
      'label' => @document[:title], 
      'metadata' => metadata.compact,
      'attribution' => attribution,
      'sequences' => [{
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/sequence/s0',
        '@type': 'sc:Sequence',
        # 'canvases' => canvases
        'canvases' => field_selector.split(';').size == 1 ? single_canvas : canvases
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

    meta.map do |x|
      x[:value].blank? ? nil : x
   end
  end

  def attribution
    [
      '',
      @document[:local_rights]
    ]
  end

  def sequences

  end

  def duration_to_float
    Time.parse(@document[:dimensions]).seconds_since_midnight
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

  def single_canvas
    [{
      '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/canvas/c0",
      '@type' => 'sc:Canvas' ,
      'label' => @document[:title],
      'items' => [{
        'id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/page/p0",
        'type' => 'AnnotationPage',
        'items' => [{
          'id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + "/annotation/a0",
          'type' => 'Annotation',
          'motivation' => 'painting',
          'body' => {
            'id' => type_selector,
            # testing this . . .
            'type' => @document[:kaltura_audio] ? 'Audio' : 'Video',
            'format' => @document[:kaltura_audio] ? 'Audio/mp4' : 'Video/mp4',
            'duration' => duration_to_float,
            'T E S T I N G MANY' => @document[:kaltura_video].split(';').size
          }
        }]
      }]
    }]
  end

  # method which creates additional canvases based on number of ids in kaltura_audio field
  def canvases
    # require logic which determines what to do if assset field cannot/need not be split. remove the redundant single_canvas method
    arr = @document[:kaltura_audio].split(';')

    arr.map.with_index do |aud, index|
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
              'id' => 'https://cdnapisec.kaltura.com/p/1369852/sp/136985200/playManifest/entryId/' + aud.strip + '/flavorId/1_atuqqpf6/format/url/protocol/http/a.mp4',
              # playlists of audio files will only function correctly if type and format is video. look into this . . .
              'type' => 'video',
              'format' => 'video/mp4',
              'duration' => duration_to_float,
            }
          }]
        }]
      }
    end
  end

end
