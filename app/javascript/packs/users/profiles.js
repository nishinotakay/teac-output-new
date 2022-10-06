$('h3').click(function(){
  $(this).text('私について');
});

$('.lesson-hover').hover(
  function(){
    $(this).find('.text-contents').addClass('text-active');
  },
  function(){
    $(this).find('.text-contents').removeClass('text-active');
  }
);
