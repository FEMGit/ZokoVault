var saveFileUrl = function() {
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
      $('#photo_url').val(Blob.key);
      $('#image_view').attr('src', Blob.url);
      $('#image_preview').attr('src', Blob.url);
      $('#new-avatar').show();
      $('#choose-avatar-section').hide();
      $('#preview-avatar-section').show();
      $('#text-avatar').hide();
      $('.remove-button').show();
    });
};

var removePhoto = function() {
  $('#photo_url').val("");
  $('#image_view').attr('src', "");
  $('#image_preview').attr('src', "");
  $('#choose-avatar-section').show();
  $('#preview-avatar-section').hide();
  $('#new-avatar').hide();
  $('#text-avatar').show();
  $('.remove-button').hide();
}
