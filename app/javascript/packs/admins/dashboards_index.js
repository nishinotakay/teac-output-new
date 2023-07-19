import '../../stylesheets/users/articles'
import '../shared/sort_and_filter'

$(function(){
  make_page()

  $('.reset-btn').on('click', function(){
    var order = search_order(location.search)
    window.location.search = order
  })

  $('.submit-btn').on('click', function(){
    var sort = 'DESC'
    var search = search_order(location.search)
    $('[id^="sort-"]').each(function(){
      sort = $(this).children(':selected').val()
      if(sort.length > 0){
        search = 'ord_' + $(this).attr('id').split('-')[1] + "=" + sort
        return false
      }
    })
    $('[id^="input-"]').each(function(){
      var input = $(this).val()
      if(input){
        search += '&flt_' + $(this).attr('id').split('-')[1] + '=' + input
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
      }
    })
    window.location.search = search
  })

  function search_order(search){
    var keys = ["ord_name", "ord_email", "ord_articles", "ord_posts"]
    var order = 'ord_id=DESC'
    $.each(keys, function(){
      if(search.indexOf(this) >= 0){
        order = search.indexOf("DESC") != -1 ? this + '=DESC' : this + '=ASC'
        return false
      }
    })
    return order
  }
})

$(function() {
  $.datepicker.setDefaults($.datepicker.regional["ja"]);
  $("#input-created_at").datepicker({
    dateFormat: "yy/mm/dd"
  });
});

$(document).ready(function(){
  $("#input-registration_date").datepicker({
    dateFormat: 'yy-mm-dd'
  });
});