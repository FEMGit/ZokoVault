var saveFileUrl = function(option) {
  option = option || ""
  filepicker.setKey("AU8hye5meSjiQ6l5oOxKFz");
  filepicker.pickAndStore({
      container: 'modal',
      customSourceContainer: 'zoku-stage',
      extensions: ['.png', '.jpg', '.PNG', '.JPG', '.jpeg', 'JPEG', '.tiff', '.TIFF', '.gif', '.GIF'],
      conversions: ['crop'],
      cropRatio: 1/1,
      cropForce: true,
      multiple: false
    },
    {
      location: "S3",
      storeContainer: "zoku-stage"
    },
    function(Blobs) {
      setViewParameters(Blobs[0].key, Blobs[0].url, option)
      $('#new-avatar' + option).show();
      $('#choose-avatar-section' + option).hide();
      $('#preview-avatar-section' + option).show();
      $('#text-avatar' + option).hide();
      $('.remove-button' + option).show();
    });
};

var removePhoto = function(option) {
  option = option || ""
  setViewParameters("", "", option)
  $('#new-avatar' + option).hide();
  $('#choose-avatar-section' + option).show();
  $('#preview-avatar-section' + option).hide();
  $('#text-avatar' + option).show();
  $('.remove-button' + option).hide();
}

var setViewParameters = function(photo_url, image_src, option) {
  $('#photo_url' + option).val(photo_url);
  $('#image_view' + option).attr('src', image_src);
  $('#image_preview' + option).attr('src', image_src);
}
