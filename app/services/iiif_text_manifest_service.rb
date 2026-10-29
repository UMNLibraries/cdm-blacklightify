class IiifTextManifestService
  PRESENTATION_CONTEXT = 'http://iiif.io/api/presentation/3/context.json'.freeze

  def initialize(id)
    @id = id
    @document = SolrDocument.find(id)
  end

  def call
    manifest
  end

  private

  def cdm_manifest
    url = 'https://cdm16022.contentdm.oclc.org/iiif/2/' + @id + '/manifest.json'
    res = Net::HTTP.get_response(URI(url))
    parsed_response = res.body
    JSON.parse(parsed_response)
  end

  def manifest
    {
      '@context' => PRESENTATION_CONTEXT,
      'id' => manifest_id,
      'type' => 'Manifest',
      'label' => language_map(@document[:title]),
      'metadata' => metadata.compact,
      'requiredStatement' => required_statement,
      'items' => items,
      'behavior' => ['paged'],
      'service' => searcher
    }.tap do |hsh|
      hsh['rights'] = @document[:rights_statement_uri] if @document[:rights_statement_uri].present?
      hsh['rendering'] = rendering_property if rendering_property.any?
      hsh['structures'] = structures if structures.any?
    end
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

  def rendering_download_path_image_dimensions
    [v2_canvases.first&.fetch('width', nil), v2_canvases.first&.fetch('height', nil)]
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
      'id' => rendering_download_path,
      'type' => rendering_format_type == 'application/pdf' ? 'Text' : 'Image',
      'label' => language_map(rendering_label),
      'format' => rendering_format_type
    }]
  end

  def manifest_id
    "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/text/manifest.json"
  end

  def language_map(value)
    values = Array.wrap(value).flatten.compact.map(&:to_s).map(&:strip).reject(&:blank?)
    return nil if values.empty?

    { 'en' => values }
  end

  def pdf?
    @document[:first_viewer_type] == 'pdf'
  end

  def items
    pdf? ? [pdf_canvas] : canvases
  end

  def pdf_canvas
    canvas_id = "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/canvas/c0"
    {
      'id' => canvas_id,
      'type' => 'Canvas',
      'label' => language_map(@document[:title]),
      'items' => [{
        'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/page/p0",
        'type' => 'AnnotationPage',
        'items' => [{
          'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/annotation/a0",
          'type' => 'Annotation',
          'motivation' => 'painting',
          'target' => canvas_id,
          'body' => {
            'id' => "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@id.split(':')[0]}/id/#{@id.split(':')[1]}",
            'type' => 'Text',
            'format' => 'application/pdf'
          }
        }]
      }],
      'thumbnail' => [{
        'id' => "#{ENV.fetch('RAILS_BASEURL', 'https://umedia.lib.umn.edu')}/static/umedia-icon-pdf.png",
        'type' => 'Image',
        'format' => 'image/png'
      }]
    }
  end

  def v2_canvases
    cdm_manifest.dig('sequences', 0, 'canvases') || []
  end

  def canvases
    v2_canvases.map.with_index do |canvas, index|
      canvas_id = canvas['@id'] || "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/canvas/c#{index}"
      annotation = canvas.dig('images', 0) || {}
      resource = annotation['resource'] || {}
      service = resource['service'] || {}
      width = canvas['width'] || resource['width']
      height = canvas['height'] || resource['height']
      annotation_body = {
        'id' => resource['@id'] || resource['id'],
        'type' => 'Image',
        'format' => resource['format'] || 'image/jpeg',
        'width' => resource['width'],
        'height' => resource['height']
      }.compact

      if service.present?
        annotation_body['service'] = [{
          'id' => service['@id'] || service['id'],
          'type' => 'ImageService2',
          'profile' => service['profile']
        }.compact]
      end

      {
        'id' => canvas_id,
        'type' => 'Canvas',
        'label' => language_map(canvas['label'] || @document[:title]),
        'height' => height,
        'width' => width,
        'items' => [{
          'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/page/p#{index}",
          'type' => 'AnnotationPage',
          'items' => [{
            'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/annotation/a#{index}",
            'type' => 'Annotation',
            'motivation' => 'painting',
            'target' => canvas_id,
            'body' => annotation_body
          }]
        }],
        'thumbnail' => [{
          'id' => resource['@id'] || resource['id'],
          'type' => 'Image',
          'format' => resource['format'] || 'image/jpeg'
        }].compact
      }.compact
    end
  end

  def structures
    canvas_references = structures_source.flat_map do |structure|
      Array.wrap(structure['canvases'])
    end.compact

    return [] if canvas_references.empty?

    [{
      'id' => "https://cdm16022.contentdm.oclc.org/iiif/#{@id}/range/r0",
      'type' => 'Range',
      'label' => language_map(@document[:title]),
      'items' => canvas_references.map do |canvas_id|
        {
          'id' => canvas_id,
          'type' => 'Canvas'
        }
      end
    }]
  end

  def structures_source
    cdm_manifest['structures'] || []
  end

  def searcher
    [{
      'id' => query_constructor,
      'type' => 'SearchService1',
      'profile' => 'http://iiif.io/api/search/1/search',
      'label' => language_map('Search within this item'),
      'service' => [{
        'id' => "#{query_constructor}/autocomplete",
        'type' => 'AutoCompleteService1',
        'profile' => 'http://iiif.io/api/search/1/autocomplete',
        'label' => language_map('Autocomplete terms')
      }]
    }]
  end

  def query_constructor
    "#{ENV.fetch('RAILS_BASE_URL', 'http://localhost:3000')}/iiif/#{@document[:id]}/search"
  end
end
