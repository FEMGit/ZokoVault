function checkURL (urlInput) {
  var string = urlInput.value;
  if (!(string.match(/^https?:/)) && string) {
    string = "http://" + string;
  }
  urlInput.value = string;
  return urlInput
}

$(document).ready(function() {
  $('input[type=url]').keydown(function(event) {
    if(event.keyCode === 13) {
      checkURL(this)
    }
  })
})
