var clearAvatarPhoto = function(suffix) {
  suffix = suffix || ""
  $('#photo_url' + suffix).val("");
  $('#image_view' + suffix).attr('src', "");
  $('#image_preview' + suffix).attr('src', "");
  $('#new-avatar' + suffix).hide();
  $('#choose-avatar-section' + suffix).show();
  $('#preview-avatar-section' + suffix).hide();
  $('#text-avatar' + suffix).show();
  $('.remove-button' + suffix).hide();
}

var setAvatarPhoto = function(suffix, preview, key) {
  suffix = suffix || ""
  $('#photo_url' + suffix).val(key)
  $('#image_view' + suffix).attr('src', preview);
  $('#image_preview' + suffix).attr('src', preview);
  $('#new-avatar' + suffix).show();
  $('#choose-avatar-section' + suffix).hide();
  $('#preview-avatar-section' + suffix).show();
  $('#text-avatar' + suffix).hide();
  $('.remove-button' + suffix).show();
}

var uploadDocumentWithFilestack = function(api_key, policy_hash) {
  var client = filestack.init(api_key, policy_hash)
  client.pick({
    storeTo: {
      location: 's3'
    }
  }).then(function(result) {
    console.log(JSON.stringify(result.filesUploaded))
  })
}

var uploadThumbnailWithFilestack = function(api_key, policy_hash, suffix) {
  var client = filestack.init(api_key, policy_hash)
  client.pick({
    accept: 'image/*',
    transformations: {
      crop: { aspectRatio: 1 / 1 },
      minDimensions: [60, 60],
      maxDimensions: [60, 60]
    },
    storeTo: {
      location: 's3'
    }
  }).then(function(result) {
    console.log(JSON.stringify(result.filesUploaded))
    setAvatarPhoto(suffix, result.url, result.key)
    console.log(JSON.stringify(result))
  })
}
