// configuration for complex objects
function iiifManifestConfig(doc) {
  const docId = doc;

  var uv = UV.init(
    "uv",
    {
      manifest: `/iiif/${docId}/text/manifest.json`,
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
}

// configuration for single images
function iiifImageConfig(doc) {
  const docId = doc;
  
  var uv = UV.init(
    "uv",
    {
      manifest: `https://cdm16022.contentdm.oclc.org/iiif/2/${docId}/manifest.json`,
      config: "/uv/config.json",
    },
  );

  // the attachment tab with viewer. taken out of the _show.html partial. minimizes error message, but still not ideal solution
  const manifest = uv.options.data.iiifManifestId;
  const btn = document.querySelector(".uv-attachment");

  btn.addEventListener("click", () => {
    var uv = UV.init(
      "uv",
      {
        manifest: manifest,
        config: "/uv/config.json",
      },
    );
  });
}
