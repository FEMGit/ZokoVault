var is_safari = navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1;
if(is_safari){
  $(document).ready(function(){
    $('.flex-boxes').masonry({
      columnWidth: '.flex-column',
      gutter: 20,
      percentPosition: true,
      itemSelector: '.flex-column'
    });
  });
}
else if(!is_safari){
  $(function(){
    $('.flex-boxes').masonry({
      columnWidth: '.flex-column',
      gutter: 20,
      percentPosition: true,
      itemSelector: '.flex-column'
    });
  });
}
