$(document).ready(function() {
  $('#goToOrderPage').click(function(){
    confirmedOrder();
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

  var $privacyPolicy = $('#privacyPolicy');
  var $agreeCheckbox = $('#agreeCheckbox');
  var $goToOrderPage = $('#goToOrderPage');

  $privacyPolicy.scroll(function(){
    if ($privacyPolicy[0].scrollHeight - $privacyPolicy.scrollTop() <= $privacyPolicy.outerHeight()) {
      $agreeCheckbox.prop('disabled', false);
    }
  });

  $agreeCheckbox.change(function() {
    $goToOrderPage.prop('disabled', !$agreeCheckbox.prop('checked'));
  });
});
