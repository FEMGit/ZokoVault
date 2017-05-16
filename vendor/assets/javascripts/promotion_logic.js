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
  return parseFloat($('#subscription-total').text().match(numberRegex))
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
  } else {
    $('#promo-code-text').html('');
  }
  $('#promo-name').text(data['id']);
  $('#promo-description').text(data['id']);
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
  $('#promo-description').text('');
  $('#promo-price').text('');
  $('#promo-row').hide();
}

function applyPromoCode() {
  $('#user_stripe_subscription_attributes_promo_code').val($('#promo_code_text_field').val());
  var data = $('#user_stripe_subscription_attributes_promo_code').serialize();
  updateSubscription()
  $.post("/account/apply_promo_code", data, updatePromoRow)
  .fail(function() {
    $('#promo-code-text').html('Error!');
  })
}

function updateSubscription() {
  $.get('/account/yearly_subscription', function() {
  }).done(function(data) {
    var subscriptions = data
    var select = 0;

    var interval = "annually";
    var today = new Date()
    var billedData = (today.getMonth() + 1) + '/' + today.getDate() + '/' + (today.getFullYear() + 1)
    if (subscriptions[select]['interval'] === 'month') {
      billedData = (today.getMonth() + 2) + '/' + today.getDate() + '/' + today.getFullYear()
      interval = "monthly";
    }
    var description = "This amount will be billed to your account on " + billedData;
    $('#subscription-description').text(description);

    var priceValue = (subscriptions[select]['amount'] / 100.0).toFixed(2)
    if (isNaN(priceValue)) {
      priceValue = '--'
    }

    var price = '$ ' + priceValue
    $('#subscription-price').text(price);
    $('#subscription-total').text(price);
    clearPromoRow();
  })
}

$(document).ready(function() {
  updateSubscription();
  clearPromoRow();
})
