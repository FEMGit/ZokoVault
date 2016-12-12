var saveFileUrl = function(option) {
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
      Blob = Blobs[0];
      var id_append = ""
      if (option === "account") {
        id_append = "_account"
      }
      $('#photo_url' + id_append).val(Blob.key);
      $('#image_view' + id_append).attr('src', Blob.url);
      $('#image_preview' + id_append).attr('src', Blob.url);
      $('#new-avatar' + id_append).show();
      $('#choose-avatar-section' + id_append).hide();
      $('#preview-avatar-section' + id_append).show();
      $('#text-avatar' + id_append).hide();
      $('.remove-button' + id_append).show();
    });
};

var removePhoto = function(option) {
  var id_append = ""
  if (option === "account") {
    id_append = "_account"
  }
  $('#photo_url' + id_append).val("");
  $('#image_view' + id_append).attr('src', "");
  $('#image_preview' + id_append).attr('src', "");
  $('#choose-avatar-section' + id_append).show();
  $('#preview-avatar-section' + id_append).hide();
  $('#new-avatar' + id_append).hide();
  $('#text-avatar' + id_append).show();
  $('.remove-button' + id_append).hide();
}
