$(document).ready(function() {
  $(window).trigger('resize')
})

function stripeTokenHandler(token) {
  var form = document.getElementById('payment-form');
  var hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);
  form.submit();
}

function stripeWindowResize(card) {
  if(window.innerWidth <= 340) {
    card.update({style: {base: {fontSize: '13px'}}})
  } else if(window.innerWidth <= 375) {
    card.update({style: {base: {fontSize: '16px'}}})
  } else {
    card.update({style: {base: {fontSize: '20px'}}})
  }
}

function headerPositionFix() {
  var headerElement = $('.app-nav').find('header')
  var offset = -headerElement.offset().top
  headerElement.css('margin-top', "+=" + offset)
}

function setupStripeCardEntryForm(key) {
  var stripe = Stripe(key);
  var elements = stripe.elements();

  var style = {
    base: {
      fontSize: '20px',
      lineHeight: '32px',
      '::placeholder': {
         color: '#CFD7E0',
       },
    },
    invalid: {
      color: 'red',
    },
  };

  var card = elements.create('card', {style: style});

  card.mount('#card-element');
  
  window.addEventListener('resize', function(event) {
    stripeWindowResize(card)
  })
  
  window.addEventListener('touchstart', function(event) {
    headerPositionFix()
  })
  
  card.on('blur', function(event) { 
    headerPositionFix()
  })
  
  card.addEventListener('change', function(event) {
    stripeWindowResize(card)
    headerPositionFix()
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  var form = document.getElementById('payment-form');
  form.addEventListener('submit', function(event) {
    event.preventDefault();
    stripe.createToken(card).then(function(result) {
      if (result.error) {
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
      } else {
        stripeTokenHandler(result.token);
      }
    });
  });
}
