var clearAvatarPhoto = function(suffix, uploadButton) {
  uploadButton = uploadButton || false
  suffix = suffix || ""
  $('#photo_url' + suffix).val("").trigger('change');
  $('#company_logo' + suffix).val("").trigger('change');
  $('#image_view' + suffix).attr('src', "");
  $('#image_preview' + suffix).attr('src', "");
  $('#new-avatar' + suffix).hide();
  $('#choose-avatar-section' + suffix).show();
  $('#preview-avatar-section' + suffix).hide();
  $('#text-avatar' + suffix).show();
  $('.remove-button' + suffix).hide();
  if (uploadButton === true) {
    $("#action-avatar-link").removeClass().addClass('button blue-button big-button')
  }
}

var setAvatarPhoto = function(suffix, preview, key, uploadButton) {
  uploadButton = uploadButton || false
  suffix = suffix || ""
  $('#photo_url' + suffix).val(key).trigger('change');
  $('#company_logo' + suffix).val(key).trigger('change');
  $('#image_view' + suffix).attr('src', preview);
  $('#image_preview' + suffix).attr('src', preview);
  $('#new-avatar' + suffix).show();
  $('#choose-avatar-section' + suffix).hide();
  $('#preview-avatar-section' + suffix).show();
  $('#text-avatar' + suffix).hide();
  $('.remove-button' + suffix).show();
  if (uploadButton === true) {
    $("#action-avatar-link").removeClass().addClass('no-underline-link')
  }
}

var uploadDocumentWithFilestack = function(api_key, policy_hash, callback) {
  var client = filestack.init(api_key, policy_hash)
  client.pick(documentUploadParams()).then(function(result) {
    if (result.filesUploaded.length == 1) {
      file = result.filesUploaded[0]
      callback(file)
    } else {
      console.log(JSON.stringify(result))
    }
  })
}

var uploadMultipleDocumentsWithFilestack = function(api_key, policy_hash, max_document_count, callback) {
  var client = filestack.init(api_key, policy_hash)
  client.pick(multipleDocumentUploadParams(max_document_count)).then(function(result) {
    files = result.filesUploaded
    callback(files)
  })
}
  
var multipleDocumentUploadParams = function(max_document_count) {
  documentParams = documentUploadParams()
  documentParams["maxFiles"] = max_document_count
  return documentParams
}

var documentUploadParams = function() {
  return {
    maxSize: 104857600,
    disableTransformer: true,
    fromSources: [
      'local_file_system', 'webcam', 'googledrive', 'dropbox', 'box', 'gmail'
    ],
    storeTo: {
      location: 's3', path: '/documents/'
    }
  }
}

var uploadThumbnailWithFilestack = function(api_key, policy_hash, suffix, square, uploadButton) {
  uploadButton = uploadButton || false
  var transformations = square ? {
    crop: { aspectRatio: 1 / 1 },
    minDimensions: [360, 360],
    maxDimensions: [360, 360]
  } : {}
  var client = filestack.init(api_key, policy_hash)
  client.pick({
    accept: 'image/*',
    fromSources: [
      'local_file_system', 'webcam', 'facebook', 'instagram',
      'googledrive', 'dropbox', 'flickr', 'picasa', 'gmail'
    ],
    transformations: transformations,
    storeTo: {
      location: 's3', path: '/avatars/'
    }
  }).then(function(result) {
    if (result.filesUploaded.length == 1) {
      file = result.filesUploaded[0]
      preview = file.url + '?signature=' + policy_hash.signature + '&policy=' + policy_hash.policy
      setAvatarPhoto(suffix, preview, file.key, uploadButton)
    } else {
      console.log(JSON.stringify(result))
    }
  })
}
