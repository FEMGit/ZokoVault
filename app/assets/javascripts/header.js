$(function(){
  //marketing website navigation
  $('#mobile-menu, #close-mobile-menu').click(function() {
     $('.slide-nav').animate({width:'toggle'},150);
  });
  //application navigation
  $('#mobile-app-menu, #close-mobile-app-menu').click(function() {
     $('.primary-nav').animate({width:'toggle'},150);
  });
  //window navigation resize reset
  $( window ).resize(function() {
    if ($(window).width() < 660) {
       $('.primary-nav, .slide-nav').css('display', '');
    }
  });
  //user menu
  $('#user-menu-toggle').click(function() {
     $('.user-menu').animate({height:'toggle'},150);
  });
});
