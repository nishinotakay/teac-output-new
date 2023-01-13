import '../../stylesheets/users/articles'

$(function(){
  var title = $('h1')
  title.wrap('<div class="form-inline title-and-buttons">')
  var t_and_btns = $('.title-and-buttons')
  t_and_btns.parent().removeClass('col-sm-6')
  t_and_btns.parent().addClass('col-sm-8')
  var reset = $('.reset-btn')
  var filter = $('.filter-modal-btn')
  var sort = $('.sort-modal-btn')
  title.after(reset)
  title.after(filter)
  title.after(sort)
  $('.title-and-buttons').children().css({'display': 'inline'})

  sort.on('click', function(){
    $('.modal-title').text('並べ替え')
    $('.submit-btn').text('並べ替える')
    $('.sort-modal').show()
  })

  filter.on('click', function(){
    $('.modal-title').text('絞り込み検索')
    $('.submit-btn').text('検索する')
    $('.filter-modal').show()
  })

  $('.modal-close').on('click', function(){
    $('.sort-modal').hide()
    $('.filter-modal').hide()
  })

  $('.reset-btn').on('click', function(){
    window.location.search = ''
  })

  $('.link-tr').hover(function(){
    var classname = $(this).next().attr('class');
    console.log(classname)
    if(classname == 'content-tr'){
      // $(this).next().hover()
      // $(this).next().css('background-color', 'var(--bs-table-hover-color)')
      $(this).next().css('background-color', 'red')
    }
  })

  $('.submit-btn').on('click', function(){
    var sort = $('#sort-select option:selected').val()
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish']
    var search = "order=" + sort
    $.each(values, function(index, value){
      var input = $('#input-' + value).val()
      if(input){
        search += '&' + value + '=' + input
      }
    })
    search += '&reset=true'
    window.location.search = search
  })
})
