$(document).on('turbolinks:load', function() {

  var $priceField = $("#price_field");
  var $quantityField = $("#quantity_field");
  var $chargeTypeSelect = $('#charge_plan_charge_type');
  var $totalAmount = $("#total_amount");

  function updateTotalAmount() {
    var price = parseInt($priceField.val()) || 0;
    var quantity = parseInt($quantityField.val()) || 0;
    var total = price * quantity;
    $totalAmount.text("合計金額: " + total + "円");
  }

  function handleChargeTypeChange() {

    var chargeType = $chargeTypeSelect.val();
    var isFree = chargeType === '無料';

    if(!isFree && $priceField.data('user-input') !== undefined){
      $priceField.val($priceField.data('user-input'));
      $quantityField.val($quantityField.data('user-input'));
    } else {
      $priceField.val(isFree ? 0 : $priceField.val());
      $quantityField.val(isFree ? 0: $quantityField.val());
      $priceField.prop('disabled', isFree);
      $quantityField.prop('disabled', isFree);
    }
    updateTotalAmount()
  }  

    $priceField.change(function(){
      $priceField.data('user-input', $priceField.val());
    });
    $quantityField.change(function(){
      $quantityField.data('user-input', $quantityField.val());
    });

  $priceField.on("input", updateTotalAmount);
  $quantityField.on("input", updateTotalAmount);
  $chargeTypeSelect.change(handleChargeTypeChange);

  handleChargeTypeChange();
  updateTotalAmount();

});
