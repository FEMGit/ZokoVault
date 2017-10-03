var isToggleShow = function(password_id) {
  toggleButtonValue = $("#toggle_" + password_id).text()
  return toggleButtonValue === "Show"
}

var togglePasswordText = function(hide) {
  hide = hide || false
  var passwordField = $('#password_field')
  var toggleButton = $('#toggle_button')
  var passwordType = passwordField.get(0).type
  if (passwordType === "text" || hide === true) {
    passwordField.attr('type', 'password')
    toggleButton.text('Show')
  } else if (passwordType === "password") {
    passwordField.attr('type', 'text')
    toggleButton.text('Hide')
  }
}

var setPasswordTextProperty = function(passwordFieldId, textValue, textField) {
  if(!textField) {
    $("#password_" + passwordFieldId).text(textValue)
  }
}

var setPasswordValueProperty = function(passwordFieldId, textValue, textField) {
  if(textField) {
    $("#password_" + passwordFieldId).val(textValue)
  }
}

var setPasswordFieldType = function(passwordFieldId, type) {
  if (type === 'text') {
    $("#password_" + passwordFieldId).attr('type', 'text')
    $("#toggle_" + passwordFieldId).text("Hide")
  } 
  else if (type === 'password') {
    $("#password_" + passwordFieldId).attr('type', 'password')
    $("#toggle_" + passwordFieldId).text("Show")
  }
}

var togglePasswordView = function(password_id, textField, hide) {
  textField = textField || false
  hide = hide || false
  var hiddenPassword = "**********"
  if (typeof password_id === 'undefined') {
    togglePasswordText(hide)
  }
  if (isToggleShow(password_id)) {
    shared_user_id = $("#shared_user_id").val();
    $.ajax({
      url: "/online_accounts/reveal_password/" + password_id + '/' + shared_user_id,
      type: 'GET',
      dataType: 'json'
    }).success(function(data) {
      if (hide === false) {
        setPasswordTextProperty(password_id, data, textField)
        setPasswordFieldType(password_id, 'text')
      } else {
        setPasswordTextProperty(password_id, hiddenPassword, textField)
        setPasswordFieldType(password_id, 'password')
      }
      setPasswordValueProperty(password_id, data, textField)
    }).fail(function(data) {
      showFlashMessageError("Error while receiving a password.", 2000)
    })
  } else {
    setPasswordTextProperty(password_id, hiddenPassword, textField)
    setPasswordFieldType(password_id, 'password')
  }
}