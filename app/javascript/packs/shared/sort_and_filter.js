window.make_page = function(){
  var title = $('h1')
  title.wrap('<div class="form-inline title-and-buttons">')
  var ttl_btns = $('.title-and-buttons')
  ttl_btns.parent().removeClass('col-sm-6')
  ttl_btns.parent().addClass('col-sm-8')
  var reset = $('.reset-btn')
  // フィルター実装時解放
  // var filter = $('.filter-modal-btn')
  var sort = $('.sort-modal-btn')
  title.after(reset)
  // フィルター実装時解放
  // title.after(filter)
  title.after(sort)
  ttl_btns.children().css({'display': 'inline'})

  sort.on('click', function(){
    $('.modal-title').text('並べ替え')
    $('.submit-btn').text('並べ替える')
    $('.sort-modal').show()
  })

  // フィルター実装時解放
  // filter.on('click', function(){
  //   $('.modal-title').text('絞り込み検索')
  //   $('.submit-btn').text('検索する')
  //   $('.filter-modal').show()
  // })

  $('.modal-close').on('click', function(){
    $('.sort-modal').hide()
    // フィルター実装時解放
    // $('.filter-modal').hide()
  })
}
