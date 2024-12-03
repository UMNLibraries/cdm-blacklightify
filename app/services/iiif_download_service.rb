class IiifDownloadService
  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def manifesttest
    manifest
  end

  private

  def iiif_manifest
    url = 'https://cdm16022.contentdm.oclc.org/iiif/2/' + @id + '/manifest.json'
    res = Net::HTTP.get_response(URI(url))
    parsed_response = res.body
    JSON.parse(parsed_response)
  end

  def get_canvas
    iiif_manifest['sequences'][0]['canvases']
  end

  def manifest
    {
      'context' => 'http://iiif.io/api/presentation/2/context.json',
      '@id' => @document[:object],
      '@type' => 'sc:Manifest',
      'label' => @document[:title],
      # 'metadata' => metadata.compact,
      # 'attribution' => attribution,
      'sequences' => [{
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/sequence/s0',
        '@type' => 'sc:Sequence',
        'rendering' => rendering_property,
        'canvases' => get_canvas
      }]
    }
  end

  def rendering_property
    [{
      '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/2/' + @id + '/full/full/0/default.jpg',
      # https://cdm16022.contentdm.oclc.org/utils/getfile/collection/p16022coll208/id/0/filename/print/page/download/fparams/forcedownload
      # this path argubaly works for complex objects, need to confirm. does not work for individual image . . . does not open in new tab . . .
      # https://cdm16022.contentdm.oclc.org/iiif/2/p16022coll208:0/full/full/0/default.jpg
      # this is an image path
      'label' => 'D O W N LOAD the original file',
      'format' => 'image/tiff'
    }]
  end
end
