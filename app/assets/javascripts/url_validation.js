function checkURL (urlInput) {
  var string = urlInput.value;
  console.log(string)
  if (!(string.match(/^https?:/)) && string) {
    string = "http://" + string;
  }
  urlInput.value = string;
  return urlInput
}
