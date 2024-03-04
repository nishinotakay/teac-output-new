$(document).ready(function() {
  $('#goToOrderPage').click(function(){
    confirmedOrder();
  });
});

function confirmedOrder(){
  var confirmOrderUrl = '/users/checkouts';
  $.ajax({
    url: confirmOrderUrl,
    type: 'POST',
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    success: function(data) {
      window.location.href = data.session.url;
    },
    error: function(error) {
      console.log(error);      
    }
  });
}
