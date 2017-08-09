var showAlertMessage = function(message, type, delay) {
  delay = delay || 3000
  $(".flash-" + type + ".flash").html(message);
  $(".flash-" + type + "-static.flash.static").html(message)
  $(".flash-" + type + ".flash").show().delay(delay).fadeOut();
  $(".flash-" + type + "-static.flash.static").show();
}