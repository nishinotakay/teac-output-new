$(document).ready(function() {
  var $priceField = $("#price_field");
  var $quantityField = $("#quantity_field");
  var $totalAmount = $("#total_amount");

  function updateTotalAmount() {
    var price = parseInt($priceField.val()) || 0;
    var quantity = parseInt($quantityField.val()) || 0;
    var total = price * quantity;
    $totalAmount.text("合計金額: " + total + "円");
  }

  $priceField.on("input", updateTotalAmount);
  $quantityField.on("input", updateTotalAmount);

  updateTotalAmount();
});
