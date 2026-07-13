class IiifTextManifestService
  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def text_manifest
    manifest
  end

  private

  def iiif_manifest
    url = 'https://cdm16022.contentdm.oclc.org/iiif/2/' + @id + '/manifest.json'
    res = Net::HTTP.get_response(URI(url))
    parsed_response = res.body
    JSON.parse(parsed_response)
  end

  def manifest
    {
      'context' => 'http://iiif.io/api/presentation/2/context.json',
      '@id' => @document[:object],
      '@type' => 'sc:Manifest',
      'label' => @document[:title],
      'metadata' => metadata.compact,
      'attribution' => attribution,
      'sequences' => is_pdf,
      'structures' => [{
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/range/r0',
        '@type' => 'sc:Range',
        'label' => @document[:title],
        'ranges' => iiif_manifest['structures'][0]['ranges'],
        'canvases' => iiif_manifest['structures'][0]['canvases'],
      }],
      'service' => searcher,
      # needs to be outside structures to work appropriately . . .
      'viewingHint' => 'paged'
    }
  end

  def metadata
    meta = [{
      :label => 'Title', # About This Item
      :value => @document[:title]
    },
    {
      :label => 'Alternative Title',
      :value => @document[:title_alternative]
    },
    {
      :label => 'Description',
      :value => @document[:description]
    },
    {
      :label => 'Date Created',
      :value => @document[:date_created]
    },
    {
      :label => 'Creator',
      :value => @document[:creator]
    },
    {
      :label => 'Contributor',
      :value => @document[:contributor]
    },
    {
      :label => 'Publisher',
      :value => @document[:publisher]
    },
    {
      :label => 'Historical Era/Period',
      :value => @document[:historical_era]
    },
    {
      :label => 'Transcription',
      :value => @document[:caption]
    },
    {
      :label => 'Additional Notes',
      :value => @document[:notes]
    },
    {
      :label => 'Subjects', # Topics
      :value => @document[:subject]
    },
    {
      :label => 'Language',
      :value => @document[:language]
    },
    {
      :label => 'Item Type', # Physical Description
      :value => @document[:types]
    },
    {
      :label => 'Format',
      :value => @document[:format_name]
    },
    {
      :label => 'Dimensions',
      :value => @document[:dimensions]
    },
    {
      :label => 'City/Township', # Geographic Location
      :value => @document[:city]
    },
    {
      :label => 'State/Province',
      :value => @document[:state]
    },
    {
      :label => 'Country',
      :value => @document[:country]
    },
    {
      :label => 'Region/Area',
      :value => @document[:region]
    },
    {
      :label => 'Continent',
      :value => @document[:Continent]
    },
    {
      :label => 'Projections',
      :value => @document[:projection]
    },
    {
      :label => 'Scale',
      :value => @document[:scale]
    },
    {
      :label => 'Coordinates',
      :value => @document[:coordinates]
    },
    {
      :label => 'GeoNames',
      :value => @document[:geonames]
    },
    {
      :label => 'Digital Collection', # Collection Information
      :value => @document[:collection_name]
    },
    {
      :label => 'Parent Collection',
      :value => @document[:parent_collection]
    },
    {
      :label => 'Contributing Organization',
      :value => @document[:contributing_organization]
    },
    {
      :label => 'Contact Information',
      :value => @document[:contact_information]
    },
    {
      :label => 'Fiscal Sponsor',
      :value => @document[:fiscal_sponsor]
    },
    {
      :label => 'Fiscal Sponsor',
      :value => @document[:fiscal_sponsor_ssi]
    },
    {
      :label => 'Local Identifier', # Identifiers
      :value => @document[:local_identifier]
    },
    {
      :label => 'Barcode Identifier',
      :value => @document[:barcode]
    },
    {
      :label => 'System Identifier',
      :value => @document[:system_identifier]
    },
    {
      :label => 'DLS Identifier',
      :value => @document[:dls_identifier]
    },
    {
      :label => 'Persistent URL (PURL)',
      :value => @document[:persistent_url]
    },
    {
      :label => 'Local Rights Statement', # Can I Use It?
      :value => @document[:local_rights] ? @document[:local_rights] : rights_statement
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

  def rendering_download_path_image_dimensions
    width, height = iiif_manifest['sequences'][0]['canvases'][0]['width'], iiif_manifest['sequences'][0]['canvases'][0]['height']
  end

  def rendering_download_path
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@id.split(':')[0]}/id/#{@id.split(':')[1]}/filename/print/page/download/fparams/forcedownload" :
    # singular image object
    "https://cdm16022.contentdm.oclc.org/utils/ajaxhelper?CISOROOT=#{@id.split(':')[0]}&CISOPTR=#{@id.split(':')[1]}&action=2&DMSCALE=100&DMWIDTH=#{rendering_download_path_image_dimensions[0]}&DMHEIGHT=#{rendering_download_path_image_dimensions[1]}"
  end

  def rendering_label
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 'Download all images (large PDF)' : 'Download full size image'
  end

  def rendering_format_type
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 'application/pdf' : 'image/jpeg'
  end

  def rendering_property
    [{
        '@id' => rendering_download_path,
        'label' => rendering_label,
        'format' => rendering_format_type
      }]
  end

  # pdf support . . .
  def mediaSequences
    [{
      "@type": "ixif:MediaSequence",
      "label": "Contents",
      "elements": [
        {
          "@id": "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@id.split(':')[0]}/id/#{@id.split(':')[1]}",
          "format": "application/pdf",
          "@type": "foaf:Document",
          "label" => @document[:title],
          "rendering": [
            {
              "@id": "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@id.split(':')[0]}/id/#{@id.split(':')[1]}",
              "format": "application/pdf",
            }
          ],
          "thumbnail": "/images/thumbnails/cf-thumb-pdf.png"
        }
      ]
    }]
  end

  def sequences
    [{
      '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/sequence/s0',
      '@type' => 'sc:Sequence',
      'label' => @document[:title],
      'rendering' => rendering_property,
      'canvases' => canvases
    }]
  end

  def is_pdf
    # determine if pdf ("viewer_type": "pdf") . . .
    @document[:first_viewer_type] == "pdf" ? mediaSequences : sequences
  end

  def canvases
    iiif_manifest['sequences'][0]['canvases']
  end
  
  def structures
    iiif_manifest['structures']
  end

  def searcher
    {
      '@content' => "http://iiif.io/api/search/0/context.json",
      '@id' => query_constructor,
      'profile' => "http://iiif.io/api/search/0/search",
      'label' => "Search within this item"
    }
  end

  def query_constructor
    "#{ENV['RAILS_BASE_URL']}/catalog/#{@document[:id]}/iiif_search"
  end
end
