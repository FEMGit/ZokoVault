var saveFileUrl = function(option) {
  option = option || ""
  filepicker.setKey("AU8hye5meSjiQ6l5oOxKFz");
    filepicker.pick({
      container: 'modal',
      customSourceContainer: 'zoku-stage',
      extensions: ['.png', '.jpg', '.PNG', '.JPG', '.jpeg', 'JPEG', '.tiff', '.TIFF', '.gif', '.GIF'],
      conversions: ['crop'],
      cropRatio: 1/1,
      cropForce: true,
      cropMin: [60, 60]
    },
    function(pickedBlob) {
      setPreview(pickedBlob.url, option)
      $('#new-avatar' + option).show();
      $('#choose-avatar-section' + option).hide();
      $('#preview-avatar-section' + option).show();
      $('#text-avatar' + option).hide();
      $('.remove-button' + option).show();
      filepicker.convert(
        pickedBlob, {
          width: 60,
          height: 60
        },
        function(convertedBlob) {
          setViewParameters(convertedBlob.key, option)
          filepicker.store(
            convertedBlob,
            {
              location: "S3",
              storeContainer: "zoku-stage"
            },
          )
        }
      )
    });
};

var removePhoto = function(option) {
  option = option || ""
  setViewParameters("", option)
  setPreview("", option)
  $('#new-avatar' + option).hide();
  $('#choose-avatar-section' + option).show();
  $('#preview-avatar-section' + option).hide();
  $('#text-avatar' + option).show();
  $('.remove-button' + option).hide();
}

var setViewParameters = function(photo_url, option) {
  $('#photo_url' + option).val(photo_url);
}

var setPreview = function(image_src, option) {
  $('#image_view' + option).attr('src', image_src);
  $('#image_preview' + option).attr('src', image_src);
}
