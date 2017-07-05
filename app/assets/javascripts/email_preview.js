var setEmailPreviewSingleDropdown = function(chosenSelector) {
  chosenSelector.on('change', function(e, params) {
    addRemoveShareInfoLineSingleDropdown(e, params)
  })
}

var setEmailPreviewMultipleDropdown = function(chosenSelector) {
  chosenSelector.on('change', function(e, params) {
    addRemoveShareInfoLineMultipleDropdown(e, params)
  })
}

var addRemoveShareInfoLineSingleDropdown = function(e, params) {
  $("#email-preview-list").find("p").remove()
  var targetId = $(e.target).attr('id')
  
  $.each($("#" + targetId + " option:selected"), function(i, val) {
    appendNewEmailPreviewLine(val.value)
  })
}

var addRemoveShareInfoLineMultipleDropdown = function(e, params) {
  var targetId = $(e.target).attr('id')
  var oldIds = []
  // Get ids for current email preview messages
  $.each($("[id^='share-contact-message']"), function(i, val) {
    var newId = val.id.match(/\d+/)[0]
    if (oldIds.indexOf(newId) < 0) {
      oldIds.push(newId)
    }
  })

  // Add messages for ids that are not in 'oldIds'
  $.each($("#" + targetId + " option:selected"), function(i, val) {
    var index = oldIds.indexOf(val.value)
    if (index >= 0) {
      oldIds.splice(index, 1)
      return true
    } else {
      appendNewEmailPreviewLine(val.value)
    }
  })
  
  // Remove messages with all unused 'oldIds' items
  for(var i = 0; i < oldIds.length; i++) {
    $("#share-contact-message-" + oldIds[i]).remove()
  }
}

var appendNewEmailPreviewLine = function(selectedContact){
  $.get('/email/email_preview_line/' + selectedContact)
  .done(function(data) {
    $('#email-preview-list').append(data)
  })
}