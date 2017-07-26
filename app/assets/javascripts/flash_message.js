var showFlashMessageError = function(msg, delayTime) {
  showMessage(msg, 'error', delayTime)
}

var showFlashMessageNotice = function(msg, delayTime) {
  showMessage(msg, 'notice', delayTime)
}

var showFlashMessageSuccess = function(msg, delayTime) {
  showMessage(msg, 'success', delayTime)
}

var showFlashMessageAlert = function(msg, delayTime) {
  showMessage(msg, 'alert', delayTime)
}

var showMessage = function(msg, type, delayTime) {
  delayTime = delayTime || 3000
  $(".flash-" + type + ".flash").html(msg);
  $(".flash-" + type + "-static.flash.static").html(msg)
  $(".flash-" + type + ".flash").show().delay(delayTime).fadeOut();
  $(".flash-" + type + "-static.flash.static").show();
}