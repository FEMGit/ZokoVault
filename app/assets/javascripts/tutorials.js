/**
 * This component handles dynamic fields on tutorials.
 * To reuse it you need to put tutorial-fields class inside the form's elements.
 * Example in page_1 partial in tutorials/home/ folder.
 */
var DynamicTutorialField = function(creationPath, destroyPath) {
  this.submitURL = creationPath;
  this.destroyURL = destroyPath;
  this.fields = '.tutorial-fields';
  this.addBtn = '.tutorial-fields .add-another-btn';
  this.savedClass = '.saved-field';
  this.addAnotherBtnListener();
};

DynamicTutorialField.prototype.addRow = function($btn) {
  var html = $btn.closest(this.fields).clone();
  $btn.closest(this.fields).after(html);
  html.find('input.repeated-field').focus().val('');
  $btn.after(this.addRemoveBtn());
  $btn.remove();
};

DynamicTutorialField.prototype.fieldIsEmpty = function($btn) {
  return $btn.siblings('input.repeated-field').val() != '';
};

DynamicTutorialField.prototype.showLittleError = function($btn) {
  $btn.siblings('input.repeated-field').addClass('input-error');
  setTimeout(function() {
    $btn.siblings('input.repeated-field').removeClass('input-error');
  }, 1000);
};

DynamicTutorialField.prototype.addRemoveBtn = function() {
  var $btn = $('<a class="medium-button outline-button inline-button">Remove</a>');
  this.removeBtnListener($btn);
  return $btn;
};

DynamicTutorialField.prototype.removeBtnListener = function($btn) {
  var that = this;
  $btn.on('click', function() {
    var id = $('FIND-ID'); //PENDANT
    that.destroy($btn, id).success(function() {
      $btn.closest(that.fields).remove();
    }).error(function() {
      console.log("Can't destroy it");
    });
  });
};

DynamicTutorialField.prototype.addAnotherBtnListener = function() {
  var that = this;
  $(document).on('click', this.addBtn, function() {
    var $btn = $(this);

    if (that.fieldIsEmpty($btn))
      that.submit($btn).success(function(data) {
        console.log(data);
        $btn.closest('input').addClass('saved-field');
        that.addRow($btn);
      }).error(function() {
        that.showLittleError($btn)
      });
    else
      that.showLittleError($btn);
  });
};

DynamicTutorialField.prototype.submit = function($btn) {
  var that = this;

  return $.ajax({
    url: that.submitURL,
    type: 'POST',
    dataType: 'application/json',
    data: $('.collect-fields input').not('.saved-field').serialize()
  });
}

DynamicTutorialField.prototype.destroy = function($btn, id) {
  var that = this;

  return $.ajax({
    url: that.destroyURL + id,
    type: 'DELETE',
    dataType: 'json'
  });
}

$(document).on('ready', function() {
  // Starting DynamicTutorialField only when tutorial-fields class is present.
  if ($('.tutorial-fields').length) {
    var create = "/financial_information/property/add_property";
    var destroy = "/financial_information/property/DESTROY_PATH"; //PENDANT

    var tutorial = new DynamicTutorialField(create, destroy);
  }
});
