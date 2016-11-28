$(document).ready(function() {

  $('.flex-boxes').masonry({
    columnWidth: '.flex-column',
    gutter: 20,
    percentPosition: true,
    itemSelector: '.flex-column'
  });

});
