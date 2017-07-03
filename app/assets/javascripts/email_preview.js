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
  if (params === undefined) {
    return
  } else if (params["selected"] !== undefined) {
    appendNewEmailPreviewLine(params["selected"])
  }
}

var addRemoveShareInfoLineMultipleDropdown = function(e, params) {
  if(params["deselected"] !== undefined) {
    $("#share-contact-message-" + params["deselected"]).remove()
  } else if (params["selected"] !== undefined) {
    appendNewEmailPreviewLine(params["selected"])
  }
}

var appendNewEmailPreviewLine = function(selectedContact){
  $.get('/email/email_preview_line/' + selectedContact)
  .done(function(data) {
    $('#email-preview-list').append(data)
  })
}