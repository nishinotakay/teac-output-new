import '../../stylesheets/users/articles'
import '../shared/sort_and_filter'

$(function(){
  make_page()

  // フィルター実装時解放
  // $('.reset-btn').on('click', function(){
  //   var search = location.search
  //   var keys = ["ord_name", "ord_email", "ord_article", "ord_ movie"]
  //   var order = ''
  //   keys.each(function(){
  //     if(search.indexOf(this) >= 0){
  //       order = search.indexOf("DESC") != -1 ? this + '=DESC' : this + '=ASC'
  //     }
  //   })
  //   window.location.search = order
  // })

  $('.submit-btn').on('click', function(){
    var sort = 'DESC'
    var search = 'ord_id=' + sort
    $('[id^="sort-"]').each(function(){
      sort = $(this).children(':selected').val()
      if(sort.length > 0){
        search = 'ord_' + $(this).attr('id').split('-')[1] + "=" + sort
        return false
      }
    })
    // フィルター実装時解放
    // var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish']
    // $.each(values, function(index, value){
    //   var input = $('#input-' + value).val()
    //   if(input){
    //     search += '&' + value + '=' + input
    //     search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
    //   }
    // })
    window.location.search = search
  })
})
