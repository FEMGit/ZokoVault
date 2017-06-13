var iosVersion = function() {
  if(/iP(hone|od|ad)/.test(navigator.platform)) {
    var v = (navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/)
    return [parseInt(v[1], 10), parseInt(v[2], 10), parseInt(v[3] || 0, 10)]
  }
}

var iosVersionGreaterThanTen = function() {
  var ios_v = iosVersion()
  return (ios_v && ios_v[0] >= 10) ? true : false
}

var iosCheckboxFromSubmit = function(checkbox_selector, formSubmit, type) {
  if (iosVersionGreaterThanTen()) {
    var checkbox = $(checkbox_selector)
    if (formSubmit !== null) {
      formSubmit(type)
    }
  }
}

var iosToggleCheckbox = function(checkbox_selector) {
  if (iosVersionGreaterThanTen()) {
    var checkbox = $(checkbox_selector)
    checkbox.next().removeClass('hidden')
    if(checkbox.prop('checked') === false) {
      checkbox.prop('checked', !checkbox.prop('checked'))
    }
  }
}

var iosClickCheckbox = function(checkbox_selector) {
  var checkbox = $(checkbox_selector)
  if (iosVersionGreaterThanTen() && checkbox.prop('checked') === true) {
    checkbox.next().addClass('hidden')
  }
}