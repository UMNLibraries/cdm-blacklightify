// makes the ajax call to the transcript partial and appends the result to the transcript_content div
function callTranscript() {
  let transcriptPath = "/" + location.href.split('/').slice(-2).join('/') + "/transcript";

  $.ajax({
    url: transcriptPath,
    cache: false,
    success: function(html){
      let parser = new DOMParser();
      doc = parser.parseFromString(html, "text/html");

      let transcriptBody = doc.querySelector('.transcriptions')
      let transcriptBody_add = doc.querySelector('.translations')

      $("#transcript_content").append(transcriptBody);
      $("#transcript_content_add").append(transcriptBody_add);
    }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const tabContainer = document.querySelector('.nav-tabs');
  
  tabContainer.addEventListener('click', (event) => {
    const clickedTab = event.target.closest('.tab');
    if (!clickedTab) return;

    callTranscript();
  });
});
