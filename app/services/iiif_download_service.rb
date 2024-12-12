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
      'attribution' => attribution,
      'sequences' => [{
        '@id' => 'https://cdm16022.contentdm.oclc.org/iiif/' + @id + '/sequence/s0',
        '@type' => 'sc:Sequence',
        'label' => @document[:title],
        'rendering' => rendering_property,
        'canvases' => get_canvas
      }],
      'structures' => get_structures
    }
  end

  # def metadata
  #   # this just mimics what contentdm produces
  #   meta = [{
  #     :label => 'Parent Collection Name',
  #     :value => @document[:parent_collection]
  #   },
  #   {
  #     :label => 'Additional Notes',
  #     :value => @document[:notes]
  #   },
  #   {
  #     :label => 'Contact Information',
  #     :value => @document[:contact_information]
  #   },
  #   {
  #     :label => 'Continent',
  #     :value => @document[:Continent]
  #   },
  #   {
  #     :label => 'Contributing Organization',
  #     :value => @document[:contributing_organization]
  #   },
  #   {
  #     :label => 'Contributor',
  #     :value => @document[:contributor]
  #   },
  #   {
  #     :label => 'Country',
  #     :value => @document[:country]
  #   },
  #   {
  #     :label => 'Date of Creation',
  #     :value => @document[:date_created]
  #   },
  #   {
  #     :label => 'Description',
  #     :value => @document[:description]
  #   },
  #   {
  #     :label => 'Dimensions',
  #     :value => duration_to_float
  #   },
  #   {
  #     :label => 'DLS Identifier',
  #     :value => @document[:description]
  #   },
  #   {
  #     :label => 'Fiscal Sponsor',
  #     :value => @document[:fiscal_sponsor]
  #   },
  #   {
  #     :label => 'Item Physical Format',
  #     :value => @document[:format]
  #   },
  #   {
  #     :label => 'Historical Era/Period',
  #     :value => @document[:historical_era]
  #   },
  #   {
  #     :label => 'Language',
  #     :value => @document[:language]
  #   },
  #   {
  #     :label => 'Local Rights Statement',
  #     :value => @document[:local_rights]
  #   },
  #   {
  #     :label => 'Persistent URL (PURL)',
  #     :value => @document[:persistent_url]
  #   },
  #   {
  #     :label => 'Publisher',
  #     :value => @document[:publisher]
  #   },
  #   {
  #     :label => 'Locally Assigned Subject Headings',
  #     :value => @document[:subject]
  #   },
  #   {
  #     :label => 'Title',
  #     :value => @document[:title]
  #   },
  #   {
  #     :label => 'Item Type',
  #     :value => @document[:types]
  #   }]

  #   meta.map do |field|
  #     field[:value].blank? ? nil : field
  #  end
  # end

  def attribution
    [ '', @document[:local_rights] ]
    # local_rights rights_statement_uri additional_rights_information standardized_rights expected_public_domain_year 
  end

  def rendering_download_path
    @document[:viewer_type] == "COMPOUND_PARENT_NO_VIEWER" ? 
    # compound objects
    "https://cdm16022.contentdm.oclc.org/utils/getfile/collection/#{@id.split(':')[0]}/id/#{@id.split(':')[1]}/filename/print/page/download/fparams/forcedownload" :
    # singular image object
    "https://cdm16022.contentdm.oclc.org/utils/ajaxhelper?CISOROOT=#{@id.split(':')[0]}&CISOPTR=#{@id.split(':')[1]}&action=2&DMSCALE=100&DMWIDTH=4052&DMHEIGHT=5040"
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

  def get_structures
    iiif_manifest['structures']
  end
end
