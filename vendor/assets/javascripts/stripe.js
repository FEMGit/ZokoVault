function paymentEntryStarted() {
  return (
      $("#user__card_number").val() != "" ||
      $("#user_subscription_attributes_expiration_month").val() != "" ||
      $("#user_subscription_attributes_expiration_year").val() != "" 
    );
}

function cardIsValidRequest(handleData) {
  var attrs = {
    number: $("#user_subscription_attributes_card_number").val(),
    exp_month: $("#user_subscription_attributes_expiration_month").val(),
    exp_year: $("#user_subscription_attributes_expiration_year").val(),
    cvc: $("#user_subscription_attributes_cvc").val() 
  }
  $.ajax({
    type: 'POST',
    url: '/account/card_validation',
    success: function() {
      handleData(true)
    },
    error: function(data) {
      $('#payment-errors').text(data["responseText"]);
      $('#submit-cc-button').prop('disabled', false);
    },
    data: attrs,
    async: false
  });
}

var cardIsValid = function() {
  var isValid = false
  cardIsValidRequest(function(cardValidationResult) { 
    isValid = cardValidationResult
  })
  return isValid
}

function addCreditCard() {
  if (paymentEntryStarted() && cardIsValid()) {
    // conditional prevents the form from breaking if not updating card
    $('#submit-cc-button').prop('disabled', true);
    $('#account-form').submit();
  }
}

function updatePromoRow(data) {
  if (isNaN(data['amount_off'])) {
    $('#promo-code-text').html('Error!');
    return
  } else {
    $('#promo-code-text').html('');
  }
  $('#promo-name').text(data['id']);
  $('#promo-description').text(data['id']);
  var discount = data['amount_off'] / 100.0
  $('#promo-price').text('-$ ' + discount);
  var numberRegex = /\d+(\.\d+)?/g
  var currentTotalValue = parseFloat($('#subscription-total').text().match(numberRegex))
  var newTotal = ((currentTotalValue - discount) < 0) ? 0 : (currentTotalValue - discount)
  $('#subscription-total').text('$ ' + newTotal);
  $('#promo-row').show();
}

function clearPromoRow(data) {
  $('#user_subscription_attributes_promo_code').val('');
  $('#promo-name').text('');
  $('#promo-description').text('');
  $('#promo-price').text('');
  $('#promo-row').hide();
}

function applyPromoCode() {
  var data = $('#user_subscription_attributes_promo_code').serialize();
  updateSubscription()
  $.post("/account/apply_promo_code", data, updatePromoRow)
  .fail(function() {
    $('#promo-code-text').html('Error!');
  })
}

function updateSubscription() {
  $.get('/account/subscriptions', function() {
  }).done(function(data) {
    var subscriptions = data
    var select = $('#user_subscription_attributes_plan_id').prop('selectedIndex');

    var interval = "annually";
    var today = new Date()
    var billedData = (today.getMonth() + 1) + '/' + today.getDate() + '/' + (today.getFullYear() + 1)
    if (subscriptions[select]['interval'] === 'month') {
      billedData = (today.getMonth() + 2) + '/' + today.getDate() + '/' + today.getFullYear()
      interval = "monthly";
    }
    var description = "This amount will be billed to your account on " + billedData;
    $('#subscription-description').text(description);

    var price = '$ ' + (subscriptions[select]['amount'] / 100.0).toFixed(2);
    $('#subscription-price').text(price);
    $('#subscription-total').text(price);
    clearPromoRow();
  })
}

$(document).ready(function() {
  updateSubscription();
  clearPromoRow();
})
