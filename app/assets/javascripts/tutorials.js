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
  this.listenUnsavedChanges();
};

DynamicTutorialField.prototype.addRow = function($btn, id) {
  var html = $btn.closest(this.fields).clone();
  $('.repeated-field').removeClass('repeated-field');
  $btn.closest(this.fields).after(html);
  html.find('input.repeated-field').focus().val('');
  $btn.after(this.addRemoveBtn(id));
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

DynamicTutorialField.prototype.addRemoveBtn = function(id) {
  var $btn = $('<a class="medium-button outline-button inline-button">Remove</a>');
  $btn.data('id', id);
  this.removeBtnListener($btn);
  return $btn;
};

DynamicTutorialField.prototype.removeBtnListener = function($btn) {
  var that = this;
  $btn.on('click', function() {
    var id = $btn.data('id');
    that.destroy($btn, id).success(function() {
      $btn.closest(that.fields).remove();
    })
  });
};

DynamicTutorialField.prototype.addAnotherBtnListener = function() {
  var that = this;
  $(document).on('click', this.addBtn, function() {
    var $btn = $(this);

    if (that.fieldIsEmpty($btn))
      that.submit($btn).success(function(data) {
        $btn.closest('.repeated-field').addClass('saved-field');
        that.addRow($btn, data.id);
      }).error(function(data) {
        that.showLittleError($btn);
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
    dataType: 'json',
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

DynamicTutorialField.prototype.dialogBehaviour = function(ev) {
  if ($('.collect-fields input.repeated-field').val() != '') {
    ev.preventDefault();
    $('.unsaved-changes-modal').click();

    $(".skip-and-continue").on("click", function() {
      $('.collect-fields input.repeated-field').val('');
      $(".modal, .modal-overlay").fadeOut(500, function() {
        $(".modal-overlay").remove();
        $('form').submit();
      });
    });

    $(".save-and-continue").on("click", function() {
      $(".modal, .modal-overlay").fadeOut(500, function() {
        $(".modal-overlay").remove();
        $('form').unbind('submit').submit();
      });
    });
  };
};

DynamicTutorialField.prototype.listenUnsavedChanges = function() {
  this.modalSettings();

  $('.skip-btn').on('click', this.dialogBehaviour);
};

DynamicTutorialField.prototype.modalSettings = function() {
  $(function() {
    var appendthis =  ("<div class='modal-overlay js-modal-close'></div>");
    $('button[data-modal-id]').click(function(e) {
      e.preventDefault();
      $("body").append(appendthis);
      $(".modal-overlay").fadeTo(500, 0.8);
      $(".js-modalbox").fadeIn(500);
      var modalBox = $(this).attr('data-modal-id');
      $('#' + modalBox).fadeIn($(this).data());
    });

    $(".js-modal-close, .modal-overlay").click(function() {
      $(".modal, .modal-overlay").fadeOut(500, function() {
        $(".modal-overlay").remove();
      });
    });
  });
}

$(document).on('ready', function() {
  // Starting DynamicTutorialField only when tutorial-fields class is present.
  var tutorial_fields = $('.tutorial-fields')
  if (tutorial_fields.length) {
    var create = ''
    var destroy = ''
    if (tutorial_fields.hasClass('property-fields')) {
      create = "/financial_information/property/add_property";
      destroy = "/financial_information/property/";
    } else if (tutorial_fields.hasClass('trust-fields')) {
      create = "/trusts/";
      destroy = "/trusts/";
    } else if (tutorial_fields.hasClass('health-fields')) {
      create = "/insurance/healths";
      destroy = "/insurance/healths/provider/";
    }

    var tutorial = new DynamicTutorialField(create, destroy);

    $('.remove-btn').each(function(){ tutorial.removeBtnListener($(this)) })
  }
});
