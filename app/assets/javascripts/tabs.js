// Load transcript content via AJAX
function callTranscript() {
  // Only run if we're on a /catalog/:id or /spotlight/:exhibit_id/catalog/:id page
  const currentPath = window.location.pathname;
  const catalogMatch = currentPath.match(/^\/catalog\/[^/]+$/);
  const spotlightMatch = currentPath.match(/^\/spotlight\/[^/]+\/catalog\/[^/]+$/);
  
  if (!catalogMatch && !spotlightMatch) {
    return; // Don't load transcript if not on a catalog or spotlight item page
  }

  let transcriptPath = "/" + window.location.pathname.split('/').slice(-2).join('/') + "/transcript";

  $.ajax({
    url: transcriptPath,
    success: function(html){
      let parser = new DOMParser();
      doc = parser.parseFromString(html, "text/html");

      let transcriptBody = doc.querySelector('.transcriptions')
      let transcriptBody_add = doc.querySelector('.translations')

      $("#transcript_content").html(transcriptBody);
      $("#transcript_content_add").html(transcriptBody_add);
    }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  // Only run if we're on a /catalog/:id page (not Spotlight)
  const currentPath = window.location.pathname;
  const catalogMatch = currentPath.match(/^\/catalog\/[^/]+$/);
  
  if (!catalogMatch) {
    return; // Don't attach listener if not on a catalog item page
  }

  const tabContainer = document.querySelector('.nav-tabs');
  
  tabContainer.addEventListener('click', (event) => {
    const clickedTab = event.target.closest('.tab');
    if (!clickedTab) return;

    callTranscript();
  });
});

document.addEventListener("turbolinks:load", () => {
  // Only run if we're on a /spotlight/:exhibit_id/catalog/:id page
  const currentPath = window.location.pathname;
  const spotlightMatch = currentPath.match(/^\/spotlight\/[^/]+\/catalog\/[^/]+$/);
  
  if (!spotlightMatch) {
    return; // Don't attach listener if not on a Spotlight catalog item page
  }

  const tabContainer = document.querySelector('.nav-tabs');
  
  tabContainer.addEventListener('click', (event) => {
    const clickedTab = event.target.closest('.tab');
    if (!clickedTab) return;

    callTranscript();
  });
});
