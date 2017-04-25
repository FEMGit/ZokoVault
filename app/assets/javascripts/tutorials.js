/**
 * This component handles dinamic fields on tutorials.
 * To reuse it you need to put tutorial-fields class inside the form's elements.
 * Example in page_1 partial in tutorials/home/ folder.
 */
var DinamicTutorialField = function () {
  this.fields = '.tutorial-fields';
  this.addBtn = '.tutorial-fields .add-another-btn';
  this.addAnotherBtnListener();
};

DinamicTutorialField.prototype.addRow = function ($btn) {
  if (this.fieldIsEmpty($btn)) {
    var html = $btn.closest(this.fields).clone();
    $btn.closest(this.fields).after(html);
    html.find('input.repeated-field').focus().val('');
    $btn.after(this.addRemoveBtn());
    $btn.remove();
  } else {
    this.showLittleError($btn);
  }
};

DinamicTutorialField.prototype.fieldIsEmpty = function ($btn) {
  return $btn.siblings('input.repeated-field').val() != '';
};

DinamicTutorialField.prototype.showLittleError = function ($btn) {
  $btn.siblings('input.repeated-field').addClass('input-error');
  setTimeout(function() {
    $btn.siblings('input.repeated-field').removeClass('input-error');
  }, 1000);
};


DinamicTutorialField.prototype.addRemoveBtn = function () {
  var $btn = $('<a class="medium-button outline-button inline-button">Remove</a>');
  this.removeBtnListener($btn);
  return $btn;
};

DinamicTutorialField.prototype.removeBtnListener = function ($btn) {
  var that = this;
  $btn.on('click', function() {
    $btn.closest(that.fields).remove();
  });
};

DinamicTutorialField.prototype.addAnotherBtnListener = function () {
  var that = this;
  $(document).on('click', this.addBtn, function() {
    that.addRow($(this));
  });
};

$(document).on('ready', function() {
  if ($('.tutorial-fields').length) {
    var tutorial = new DinamicTutorialField();
  }
});
