var massUploadFilesToPage = function(files){
  var sharedUserId = $("#shared_user_id").val()
  $.ajax({
    url: "/documents/mass_document_upload" + "/" + sharedUserId,
    type: "POST",
    dataType: 'json',
    data: { "mass_upload_files": JSON.stringify(files) },
    success: function(data) {
      showAlertMessage(data["message"], 'success')
      tableUpdate(data.documents)
    },
    error: function(data) {
      showAlertMessage(data.responseJSON["error"], 'error')
    }
  })
}

var tableUpdate = function(documents) {
  var table = $('#documents-table').DataTable();
  for(var i = 0; i < documents.length; i++) {
    var data = documents[i]
    var sharedUserIdValue = $("#shared_user_id").val()
    var sharedUserPresent = (sharedUserIdValue !== undefined && sharedUserIdValue !== "")
    
    var primaryTag = "<span class='doc-tag'>" + data.primary_tag + "</span>"
    var secondaryTag = (data.secondary_tag !== undefined) ? ("<span class='doc-tag secondary-tag'>" + data.secondary_tag + "</span>") : ""
    var documentPath = "<a href='" + data.document_path + "'>" + data.name + "</a>"
    var editAction = "<a class='outline-button small-button' href='/documents/edit/" + data.uuid + "/" + sharedUserIdValue + "'>Edit</a>"
    var deleteAction = "<a data-confirm='Are you sure?' class='outline-button small-button ml-4' rel='nofollow' data-method='delete' href='/documents/" + data.uuid + "'>Delete</a>"
    var actions = editAction + ((sharedUserPresent === true) ? "" : deleteAction)

    table.row.add([
      documentPath,
      data.modified_date,
      primaryTag + secondaryTag,
      data.share_contacts,
      '',
      actions
    ]).draw(false)
  }
  // This is a hack to redraw table with all changes saved
  $(".nosort").click()
}
