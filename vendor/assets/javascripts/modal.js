$(function(){

  //SOMEONE PLEASE FIX THIS GARBAGE
  var appendthis =  ("<div class='modal-overlay js-modal-close'></div>");

  $('button[data-modal-id]').click(function(e) {
    e.preventDefault();
    $("body").append(appendthis);
    $(".modal-overlay").fadeTo(500, 0.8);
    $(".js-modalbox").fadeIn(500);
    var modalBox = $(this).attr('data-modal-id');
    $('#'+modalBox).fadeIn($(this).data());
  });


  $(".js-modal-close, .modal-overlay").click(function() {
    $(".modal, .modal-overlay").fadeOut(500, function() {
      $(".modal-overlay").remove();
    });
  });

  //ESPECIALLY THIS GARBAGE
  $(window).resize(function() {
    $(".large-modal").css({
      top: ($(window).height() - $(".modal").outerHeight()) / 2,
      left: ($(window).width() - $(".large-modal").outerWidth()) / 2,
    });
  });
  $(window).resize(function() {
    $(".medium-modal").css({
      top: ($(window).height() - $(".modal").outerHeight()) / 2,
      left: ($(window).width() - $(".medium-modal").outerWidth()) / 2,
    });
  });
  $(window).resize(function() {
    $(".small-modal").css({
      top: ($(window).height() - $(".modal").outerHeight()) / 2,
      left: ($(window).width() - $(".small-modal").outerWidth()) / 2,
    });
  });
  $(window).resize();

});
