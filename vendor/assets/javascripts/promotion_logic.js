var discount = function(data, currentTotalValue) {
  var discountValue = 0
  if (data['amount_off'] != null) {
    discountValue = data['amount_off'] / 100.0
  } else if(data['percent_off'] != null) {
    discountValue = (currentTotalValue * data['percent_off']) / 100.0
  }
  return discountValue.toFixed(2)
}

var currentTotal = function() {
  var numberRegex = /\d+(\.\d+)?/g
  return parseFloat($('#subscription-price').text().match(numberRegex))
}

var checkError = function(data) {
  if(data['status'] === 500 && data['message'] != null) {
    $('#promo-code-text').html(data['message']);
  }
}

function updatePromoRow(data) {
  if (isNaN(data['amount_off']) && isNaN(data['percent_off'])) {
    $('#promo-code-text').html('Error!');
    $('#user_stripe_subscription_attributes_promo_code').val('')
    checkError(data)
    return
  }
  $('#promo-code-text').html('');
  $('#promo-name').text(data['id']);
  var currentTotalValue = currentTotal()
  var discountValue = discount(data, currentTotalValue)
  $('#promo-price').text('-$ ' + discountValue);
  var newTotal = ((currentTotalValue - discountValue) < 0) ? 0 : +(currentTotalValue - discountValue).toFixed(2)
  $('#subscription-total').text('$ ' + newTotal);
  $('#promo-row').show();
}

function clearPromoRow(data) {
  $('#promo_code_text_field').val('');
  $('#promo-name').text('');
  $('#promo-price').text('');
  $('#promo-row').hide();
}

function applyPromoCode() {
  $('#user_stripe_subscription_attributes_promo_code').val($('#promo_code_text_field').val());
  var data = $('#user_stripe_subscription_attributes_promo_code').serialize();
  $.post("/account/apply_promo_code", data, updatePromoRow)
  .fail(function() {
    $('#promo-code-text').html('Error!');
  })
}

$(document).ready(function() {
  clearPromoRow();
})
