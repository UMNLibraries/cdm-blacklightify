// uv configuration for complex objects
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

// uv configuration for single images
function iiifImageConfig(doc) {
  const docId = doc;
  const btn = document.querySelector(".uv-attachment");

  function uvImageConfig() {
    var uv = UV.init(
      "uv",
      {
        manifest: `https://cdm16022.contentdm.oclc.org/iiif/2/${docId}/manifest.json`,
        config: "/uv/config.json",
      },
    );
  }

  if (btn) {
    btn.addEventListener("click", () => {
      uvImageConfig()
    });
  }

  uvImageConfig()
}
