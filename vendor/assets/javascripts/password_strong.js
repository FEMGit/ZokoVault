  var setConditionFailed = function(condition_selector) {
    condition_selector.addClass('conditions-fail')
    condition_selector.removeClass('conditions-met')
    var useElement = condition_selector.find('svg').find('use')[0];
    useElement.href.baseVal = '#icon-x-1'
  }
  
  var setConditionMet = function(condition_selector) {
    condition_selector.removeClass('conditions-fail')
    condition_selector.addClass('conditions-met')
    var useElement = condition_selector.find('svg').find('use')[0];
    useElement.href.baseVal = '#icon-checkmark-1'
  }
  
  var tenCharactersLong = function(password) {
    if (password.length >= 10) {
      setConditionMet($('#ten_characters_condition'))
    } else {
      setConditionFailed($('#ten_characters_condition'))
    }
  }
  
  var upperAndLowerCase = function(password) {
    if (/[A-Z]/.test(password) && (/[a-z]/).test(password)) {
      setConditionMet($('#upper_lower_case_condition'))
    } else {
      setConditionFailed($('#upper_lower_case_condition'))
    }
  }
  
  var containsNumber = function(password) {
    if (/\d/.test(password)) {
      setConditionMet($('#number_condition'))
    } else {
      setConditionFailed($('#number_condition'))
    }
  }
  
  var containsSymbol = function(password) {
    if (/\W+/.test(password)) {
      setConditionMet($('#special_characters_condition'))
    } else {
      setConditionFailed($('#special_characters_condition'))
    }
  }
  
  var isValidated = function() {
    return $('#ten_characters_condition').hasClass('conditions-met') &&
      $('#upper_lower_case_condition').hasClass('conditions-met') &&
      $('#number_condition').hasClass('conditions-met') &&
      $('#special_characters_condition').hasClass('conditions-met')
  }
  
  var passwordValidate = function(password_selector) {
    password_selector.on('click', function() {
      $('.password-validation').addClass('displayed')
    })
    password_selector.on('keyup', function(e) {
      var password = password_selector.val()
      tenCharactersLong(password)
      upperAndLowerCase(password)
      containsNumber(password)
      containsSymbol(password)

      if (isValidated()) {
        $('.not-validated').hide()
        $('.validated').show()
      } else {
        $('.not-validated').show()
        $('.validated').hide()
      }
    })
  }