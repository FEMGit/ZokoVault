var saveFileUrl = function(){
  filepicker.setKey("AU8hye5meSjiQ6l5oOxKFz");
  filepicker.pickAndStore({
      customSourceContainer: 'zoku-stage',
      extensions: ['.png', '.jpg', '.PNG', '.JPG', '.jpeg', 'JPEG', '.tiff', '.TIFF', '.gif', '.GIF'],
      conversions: ['crop'],
      cropMax: [400, 400],
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
    });
  };