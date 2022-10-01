window.onload = function(){
  $('tr[data-href]').click(function(e){
    if (!$(e.target).is('a')) {
      window.location = $(this).data('href');
    };
  })
}
