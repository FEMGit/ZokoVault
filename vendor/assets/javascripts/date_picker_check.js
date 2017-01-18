if (Modernizr.inputtypes.date) {
    $('#html-5-date').show();
    $('#html-5-date').prop('disabled', false);
    $('#datepicker-date').hide();
    $('#datepicker-date').prop('disabled', true);
  } else {
    $('#html-5-date').hide();
    $('#html-5-date').prop('disabled', true);
    $('#datepicker-date').show();
    $('#datepicker-date').prop('disabled', false);
    $('#datepicker-date').mask('99/99/9999', {placeholder: 'mm/dd/yyyy'});
  }