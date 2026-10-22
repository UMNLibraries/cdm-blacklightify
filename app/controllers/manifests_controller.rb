class ManifestsController < ApplicationController
  # CORS proxy for IIIF manifests
  # Fetches manifests server-side to bypass browser CORS restrictions in development
  
  def cdm
    doc_id = params[:id]
    manifest_url = "https://cdm16022.contentdm.oclc.org/iiif/2/#{doc_id}/manifest.json"
    
    begin
      response = Net::HTTP.get_response(URI(manifest_url))
      
      if response.is_a?(Net::HTTPSuccess)
        # Serve the manifest without CORS restrictions
        render json: JSON.parse(response.body), status: 200
      else
        render json: { error: "Manifest not found" }, status: 404
      end
    rescue StandardError => e
      render json: { error: "Failed to fetch manifest: #{e.message}" }, status: 500
    end
  end
end
