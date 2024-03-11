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

    var isFree = $chargeTypeSelect.val() === '無料';
    $priceField.val(isFree ? 0 : $priceField.data('default'));
    $quantityField.val(isFree ? 0 : $quantityField.data('default'));
    $priceField.prop('disabled', isFree);
    $quantityField.prop('disabled', isFree);
    $totalAmount.text("合計金額:" + (isFree ? "0" : total) + "円");
  }

  $priceField.on("input", updateTotalAmount);
  $quantityField.on("input", updateTotalAmount);
  $chargeTypeSelect.change(handleChargeTypeChange);

  handleChargeTypeChange();
  updateTotalAmount();

});
