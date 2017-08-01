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

var setPromoErrorMessage = function(data) {
  if(data['status'] === 500 && data['message'] != null) {
    $('#promo-code-text').html(data['message']);
  } else {
    $('#promo-code-text').html('Error!');
  }
}

function updatePromoRow(promo, data) {
  $('#promo-code-text').html('');
  $('#promo-name').text(data['id']);
  var currentTotalValue = currentTotal()
  var discountValue = discount(data, currentTotalValue)
  $('#promo-price').text('-$' + discountValue);
  var newTotal = ((currentTotalValue - discountValue) < 0) ? 0 : +(currentTotalValue - discountValue).toFixed(2)
  $('#subscription-total').text('$' + newTotal);
  $('#promo-row').show();
}

function clearPromoRow() {
  $('#user_stripe_subscription_attributes_promo_code').val('');
  $('#user_stripe_subscription_attributes_promo_code').removeData('promo_data');
  $('#promo_code_text_field').val('');
  $('#promo-name').text('');
  $('#promo-price').text('');
  $('#promo-row').hide();
}

function promoLookupCallback(promo, data) {
  if (isNaN(data['amount_off']) && isNaN(data['percent_off'])) {
    setPromoErrorMessage(data);
  } else {
    $('#user_stripe_subscription_attributes_promo_code').val(promo);
    $('#user_stripe_subscription_attributes_promo_code').data('promo_data', data);
    updatePromoRow(promo, data);
  }
}

function applyPromoCode() {
  var promo = $('#promo_code_text_field').val();
  var payload = {'user[stripe_subscription_attributes][promo_code]': promo};
  $.post("/account/apply_promo_code", payload, function(data) {
    promoLookupCallback(promo, data);
  }).fail(function() {
    $('#promo-code-text').html('Error!');
  })
}

function updateSubscription(select) {
  var option = select.options[select.selectedIndex];
  var newPrice = option.getAttribute('data-price');
  $('#subscription-price').text('$' + newPrice);
  var promo = $('#user_stripe_subscription_attributes_promo_code').val();
  var data  = $('#user_stripe_subscription_attributes_promo_code').data('promo_data');
  if (promo && data) {
    updatePromoRow(promo, data);
  } else {
    clearPromoRow();
    $('#subscription-total').text('$' + newPrice);
  }
}

$(document).ready(function() {
  clearPromoRow();
})
