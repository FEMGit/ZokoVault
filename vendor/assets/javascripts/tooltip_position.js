var headerHeight = 80;
jQuery.expr.filters.offscreenUp = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.top - headerHeight) < 0;
};
  
jQuery.expr.filters.offscreenDown = function(el) {
  var rect = el.getBoundingClientRect();
  return rect.bottom > window.innerHeight;
};

jQuery.expr.filters.screenUpFree = function(el) {
  var rect = el.getBoundingClientRect();
  return (rect.top - headerHeight) >= 0;
};

  
$(document).ready(function(){
  $('.tooltip-item')
  .mouseenter(function() {
    var tooltip = $(this).find('.tooltip');
    if(tooltip.is(':offscreenDown')) {
      tooltip.removeClass("bottom");
      tooltip.addClass("top");
    }
    if (tooltip.is(':offscreenUp')) {
      tooltip.addClass("bottom");
      tooltip.removeClass("top");
    }
  });
});