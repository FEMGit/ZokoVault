jQuery.expr.filters.offscreenUp = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.top - topMargin()) < 0;
};
  
jQuery.expr.filters.offscreenDown = function(el) {
  var rect = el.getBoundingClientRect();
  return rect.bottom > window.innerHeight;
};

jQuery.expr.filters.offscreenRight = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.right + 20) > window.innerWidth;
};

jQuery.expr.filters.screenRightFree = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.right + 20) <= (window.innerWidth - rect.width);
};

jQuery.expr.filters.screenUpFree = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.top - topMargin()) >= 0;
};

jQuery.expr.filters.screenDownFree = function(el) {
  var rect = el.getBoundingClientRect();
  return rect.bottom <= window.innerHeight;
};

var topMargin = function() {
  if (window.matchMedia("(max-width: 850px)").matches) {
    return 200;
  } else {
    return 145;
  }
}
  
$(document).ready(function(){
  $('.tooltip-item')
  .mouseenter(function() {
    var tooltip = $(this).find('.tooltip');
    if (tooltip.is(':offscreenUp')) {
      tooltip.addClass("bottom");
      tooltip.removeClass("top");
    }
    if (tooltip.is(':screenDownFree')) {
      tooltip.addClass("bottom");
      tooltip.removeClass("top");
    }
    if(tooltip.is(':offscreenDown')) {
      tooltip.removeClass("bottom");
      tooltip.addClass("top");
    }
    if (tooltip.is(':screenRightFree')) {
      tooltip.addClass("right");
      tooltip.removeClass("left");
    }
    if (tooltip.is(':offscreenRight')) {
      tooltip.addClass("left");
      tooltip.removeClass("right");
    }
  });
});