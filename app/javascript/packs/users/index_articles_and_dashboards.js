import '../../stylesheets/users/articles'

$(function(){
  var title = $('h1')
  title.wrap('<div class="form-inline title-and-buttons">')
  var t_and_btns = $('.title-and-buttons')
  t_and_btns.parent().removeClass('col-sm-6')
  t_and_btns.parent().addClass('col-sm-10')
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
    var search = location.search
    if(search.indexOf("order=") != -1){
      window.location.search = search.indexOf("DESC") != -1 ? 'order=DESC' : 'order=ASC'
    }else{
      window.location.search = ''
    }
  })

  // テーブルにコンテンツを追加するときにコメントイン
  // $('.link-tr').hover(function(){
  //   var classname = $(this).next().attr('class');
  //   if(classname == 'content-tr'){
  //     // $(this).next().hover()
  //     // $(this).next().css('background-color', 'var(--bs-table-hover-color)')
  //     $(this).next().css('background-color', 'red')
  //   }
  // })

  $('.submit-btn').on('click', function(){
    var sort = $('#sort-select option:selected').val()
    var search = "order=" + sort
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body', 'post']
    $.each(values, function(index, value){
      var input = $('#input-' + value).val()
      if(input){
        search += '&' + value + '=' + input
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
      }
    })
    window.location.search = search
  })

  $('.submit-btn-admin').on('click', function(){
    var search = "order=DESC"
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body']
    $.each(values, function(index, value){
      var input = $('#input-' + value).val()
      if(input){
        search += '&' + value + '=' + input
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
      }
    })
    window.location.search = search
  })
})
