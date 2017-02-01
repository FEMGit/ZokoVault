  var financialValueSignUpdate = function(typeDropDownSelector, valueFieldSelector) {
    $(typeDropDownSelector).change(updateValues(typeDropDownSelector, valueFieldSelector));
  }

  var updateValues = function(typeDropDownSelector, valueFieldSelector){
    var type = $(typeDropDownSelector).val()
    var url = '/financial_information/value_negative/' + type;
    
    $.get(url, function(data) {
      var value = $(valueFieldSelector).val()
      $(valueFieldSelector).autoNumeric('init', {vMin: '0', vMax: '999999999', aSign: "$"})
      if(data === true) {
        $(valueFieldSelector).autoNumeric('update', {aSign: '-$' })
        $(valueFieldSelector).css('color', 'red')
      } else {
        $(valueFieldSelector).autoNumeric('update', {aSign: '$' })
         $(valueFieldSelector).css('color', 'black')
      }
    });
  }