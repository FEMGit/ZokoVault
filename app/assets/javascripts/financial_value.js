  var financialValueSignUpdate = function(typeDropDownSelector, valueFieldSelector) {
    $(typeDropDownSelector).change(updateValues(typeDropDownSelector, valueFieldSelector));
  }

  var updateValues = function(typeDropDownSelector, valueFieldSelector, type) {
    if (type === undefined) {
      var type = $(typeDropDownSelector).val()
    }
    var url = '/financial_information/value_negative/' + type;
    
    $.get(url, function(data) {
      var value = $(valueFieldSelector).val()
      initAutonumeric(valueFieldSelector)
      setPositiveNegativeStyle(valueFieldSelector, data)
    });
  }
  
  var updateAllValues = function(valueFieldSelectorPrefix, idTypesCollection) {
    var url = '/financial_information/value_negative/';
    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'json',
      data: { data: idTypesCollection },
      success: function(data) {
        data.forEach(function(el) {
          var valueFieldSelector = "#" + valueFieldSelectorPrefix + el[0]
          setPositiveNegativeStyle(valueFieldSelector, el[1])
        })
      }
    });
  }
  
  var setPositiveNegativeStyle = function(valueFieldSelector, negative) {
    if(negative === true) {
      $(valueFieldSelector).autoNumeric('update', {aSign: '-$' })
      $(valueFieldSelector).css('color', 'red')
    } else {
      $(valueFieldSelector).autoNumeric('update', {aSign: '$' })
      $(valueFieldSelector).css('color', 'black')
    }
  }
  
  var setValue = function(valueFieldSelector, value, negative) {
    initAutonumeric(valueFieldSelector, negative)
    $(valueFieldSelector).autoNumeric('set', currencyToNumber(value))
    $(valueFieldSelector).blur()
  };
  
  var initAutonumeric = function(valueFieldSelector, negative) {
    negative = negative || false
    if (negative === true) {
      $(valueFieldSelector).autoNumeric('init', {vMin: '0', vMax: '999999999', aSign: "-$"})
      $(valueFieldSelector).css('color', 'red')
    } else {
      $(valueFieldSelector).autoNumeric('init', {vMin: '0', vMax: '999999999', aSign: "$"})
    }
  };
  
  var currencyToNumber = function(value) {
    if (!isNaN(parseFloat(value)) && isFinite(value)) {
      return value
    } else if (value == null) {
      return 0
    } else {
      var numberCurrency = value.replace(/\$/g, '')
      return Math.abs(numberCurrency.replace(/,/g, ''))
    }
  }