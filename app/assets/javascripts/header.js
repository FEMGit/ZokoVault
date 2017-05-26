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
    toggleNavigationMenu('primary-nav', 800)
    toggleNavigationMenu('slide-nav', 850)
  });
  //user menu
  $('#user-menu-toggle').click(function() {
     $('.user-menu').animate({height:'toggle'},150);
  });
  
  var toggleNavigationMenu = function(className, width) {
    if ($(window).width() <= width) {
       $('.' + className).css('display', '');
    } else {
       $('.' + className).css('display', 'block');
    }
  }
});
