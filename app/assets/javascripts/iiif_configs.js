// uv configuration for complex objects
function iiifManifestConfig(doc) {
  const docId = doc;

  // Ensure UV is loaded
  if (typeof UV === 'undefined') {
    console.warn('UV not loaded yet, retrying...');
    setTimeout(() => iiifManifestConfig(doc), 100);
    return;
  }

  const manifestUrl = `/iiif/${docId}/text/manifest.json`;
  
  // Test manifest availability before initializing UV
  fetch(manifestUrl, { method: 'HEAD' })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      
      var uv = UV.init(
        "uv",
        {
          manifest: manifestUrl,
          config: "/uv/uvconfig.json",
        },
      );

      uv.on("configure", function ({ config, cb }) {
        cb({
          modules: {
            pagingHeaderPanel: {
              options: {
                autoCompleteBoxEnabled: false,
                imageSelectionBoxEnabled: true,
              }
            },
            pdfCenterPanel: {
              options: {
                titleEnabled: false,
                subtitleEnabled: true,
                mostSpecificRequiredStatement: true,
                requiredStatementEnabled: true,
                usePdfJs: false,
              }
            }
          }
        });
      });
    })
    .catch(error => {
      console.warn('Media unavailable:', error);
      // Silently fail - page continues with metadata and MLT below
    });
}

// uv configuration for single images
function iiifImageConfig(doc) {
  const docId = doc;
  const btn = document.querySelector(".uv-attachment");

  // Ensure UV is loaded
  if (typeof UV === 'undefined') {
    console.warn('UV not loaded yet, retrying...');
    setTimeout(() => iiifImageConfig(doc), 100);
    return;
  }

  function uvImageConfig() {
    // Use CORS proxy in development/localhost, direct URL in production
    const manifestUrl = window.location.hostname === 'localhost' 
      ? `/manifests/cdm/${docId}` 
      : `https://cdm16022.contentdm.oclc.org/iiif/2/${docId}/manifest.json`;
    
    // Test manifest availability before initializing UV
    fetch(manifestUrl, { method: 'HEAD' })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        var uv = UV.init(
          "uv",
          {
            manifest: manifestUrl,
            config: "/uv/config.json",
          },
        );
      })
      .catch(error => {
        console.warn('Media unavailable:', error);
        // Silently fail - page continues with metadata and MLT below
      });
  }

  if (btn) {
    btn.addEventListener("click", () => {
      uvImageConfig()
    });
  }

  uvImageConfig()
}
