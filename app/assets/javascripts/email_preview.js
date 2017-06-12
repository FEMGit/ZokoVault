var setEmailPreview = function(chosen_selector) {
  chosen_selector.on('change', function(e, params) {
    addRemoveShareInfoLine(e, params)
  })
}

var addRemoveShareInfoLine = function(e, params) {
  if(params["deselected"] !== undefined) {
    $("#share-contact-message-" + params["deselected"]).remove()
  } else if (params["selected"] !== undefined) {
    $.get('/email/email_preview_line/' + params["selected"])
    .done(function(data) {
      $('#email-preview-list').append(data)
    })
 }
}
