if( /Android/i.test(navigator.userAgent)) {
  function headerPositionFix() {
    var headerElement = $('.app-nav').find('header')
    var offset = -headerElement.offset().top
    headerElement.css('top', "+=" + offset)
    headerElement.css('margin-bottom', "+=" + offset)
  }

  $("input[type='text'], textarea, input[type='password']").on('focus blur', function() {
    headerPositionFix()
  })

  $("div.content").on("scroll", function() {
    headerPositionFix()
  })
}