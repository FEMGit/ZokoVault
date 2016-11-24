function checkURL (urlInput) {
  var string = urlInput.value;
  if (!(string.match(/^https?:/))) {
    string = "http://" + string;
  }
  urlInput.value = string;
  return urlInput
}