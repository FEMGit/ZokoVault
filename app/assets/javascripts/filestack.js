var clearAvatarPhoto = function(suffix) {
  suffix = suffix || ""
  $('#photo_url' + suffix).val("");
  $('#company_logo' + suffix).val("");
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
  $('#company_logo' + suffix).val(key);
  $('#image_view' + suffix).attr('src', preview);
  $('#image_preview' + suffix).attr('src', preview);
  $('#new-avatar' + suffix).show();
  $('#choose-avatar-section' + suffix).hide();
  $('#preview-avatar-section' + suffix).show();
  $('#text-avatar' + suffix).hide();
  $('.remove-button' + suffix).show();
}

var uploadDocumentWithFilestack = function(api_key, policy_hash, callback) {
  var client = filestack.init(api_key, policy_hash)
  client.pick({
    maxSize: 104857600,
    fromSources: [
      'local_file_system', 'webcam', 'googledrive', 'dropbox', 'box', 'gmail'
    ],
    storeTo: {
      location: 's3', path: '/documents/'
    }
  }).then(function(result) {
    if (result.filesUploaded.length == 1) {
      file = result.filesUploaded[0]
      callback(file)
    } else {
      console.log(JSON.stringify(result))
    }
  })
}

var uploadThumbnailWithFilestack = function(api_key, policy_hash, suffix) {
  var client = filestack.init(api_key, policy_hash)
  client.pick({
    accept: 'image/*',
    fromSources: [
      'local_file_system', 'webcam', 'facebook', 'instagram',
      'googledrive', 'dropbox', 'flickr', 'picasa', 'gmail'
    ],
    transformations: {
      crop: { aspectRatio: 1 / 1 },
      minDimensions: [360, 360],
      maxDimensions: [360, 360]
    },
    storeTo: {
      location: 's3', path: '/avatars/'
    }
  }).then(function(result) {
    if (result.filesUploaded.length == 1) {
      file = result.filesUploaded[0]
      setAvatarPhoto(suffix, file.url, file.key)
    } else {
      console.log(JSON.stringify(result))
    }
  })
}
