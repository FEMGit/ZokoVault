/**
 * This component handles dynamic fields on tutorials.
 * To reuse it you need to put tutorial-fields class inside the form's elements.
 * Example in page_1 partial in tutorials/home/ folder.
 */
var modalScreenShift = function(element) {
  var offset = $(document).scrollTop()
  element.css("margin-top", offset + "px")
}

var addErrorOnChange = function(field, fieldWithErrorClass) {
  fieldWithErrorClass = fieldWithErrorClass || field
  fieldWithErrorClass.addClass('input-error');
  field.on('change keydown paste input', function(event) {
    var selectedValue = event.target.value.trim()
    if (!selectedValue.length) {
      fieldWithErrorClass.addClass('input-error');
    } else {
      fieldWithErrorClass.removeClass('input-error');
    }
  })
}

var highlightErrorField = function(fieldWithErrorClass) {
  fieldWithErrorClass.addClass('input-error')
  setTimeout(function() {
    fieldWithErrorClass.removeClass('input-error')
  }, 1000)
}

var highlightOrAddError = function(isNewTutorial, field, fieldWithErrorClass) {
  fieldWithErrorClass = fieldWithErrorClass || field
  if (isNewTutorial) {
    highlightErrorField(fieldWithErrorClass)
  } else {
    addErrorOnChange(field, fieldWithErrorClass)
  }
}

var getTutorialInputTextField = function(selector) {
  return selector.find("input[type='text']")
}

var getMultipleSelectField = function(selector) {
  return selector.find('.chosen-styled-select.repeated-field')
}

var getMultipleSelectValue = function(multiselectSelector) {
  return multiselectSelector.find('.chosen-select').val()
}

var getMultipleSelectChoices = function(multiselectSelector) {
  return multiselectSelector.find('[id^="tutorial_multiple_types"].chosen-container > ul.chosen-choices')
}

var FieldsValidate = function(){
  var tutorialFields = $(".tutorial-fields")
  var errorsCount = 0
  $.each(tutorialFields, function(index, value) {
    var textField = getTutorialInputTextField($(value))
    var multipleSelect = getMultipleSelectField($(value))
    var multipleSelectValue = getMultipleSelectValue(multipleSelect)
    var multipleSelectChoices = getMultipleSelectChoices(multipleSelect)
    var id = $(value).find('a').last().attr('data-id')
    var name = textField.val()
    var isNewTutorial = $(value).hasClass('add-tutorial')

    // Already saved tutorial has an error: at least one field is empty
    // New tutorial has an error: only one field is filled
    if ((!isNewTutorial && (!name.trim().length || (multipleSelect.length > 0 && multipleSelectValue === null))) ||
         (isNewTutorial && ((name.trim().length > 0 && (multipleSelect.length > 0 && multipleSelectValue === null)) ||
                            (!name.trim().length && (multipleSelect.length > 0 && multipleSelectValue !== null))))) {
      errorsCount++
      if (!name.trim().length) {
        highlightOrAddError(isNewTutorial, textField)
      }

      if (multipleSelectValue === null) {
        highlightOrAddError(isNewTutorial, multipleSelect, multipleSelectChoices)
      }
    }
  })
  return errorsCount === 0
}

var DynamicTutorialField = function(creationPath, destroyPath, updatePath) {
  this.submitURL = creationPath;
  this.destroyURL = destroyPath;
  this.updateURL = updatePath;
  this.fields = '.tutorial-fields';
  this.addBtn = '.tutorial-fields .add-another-btn';
  this.savedClass = '.saved-field';
  this.addAnotherBtnListener();
  this.listenUnsavedChanges();
};

DynamicTutorialField.prototype.updateAll = function () {
  var that = this
  var request = '{ "update_fields": [ '
  var tutorialFields = $(".tutorial-fields").not('.add-tutorial')
  $.each(tutorialFields, function(index, value) {
    var id = $(value).find('a').last().attr('data-id')
    var name = $(value).find("input[type='text']").val()
    var select = $(value).find('select').val()
    if (select == null) {
      request += '{ ' + ' "id" : ' + id + ', "name" :"' + name + '"}'
    } else {
      request += '{ ' + ' "id" : ' + id + ', "name" :"' + name + '",' + '"types": [' 
      
      if (select instanceof Array) {
        for(var i = 0; i < select.length; i++) {
          request += '"' + select[i] + '"'
          if (i < select.length - 1) {
            request += ","
          }
        }
      } else {
        request += '"' + select + '"'
      }
      request += '] }'
    }
    
    if (index < tutorialFields.length - 1) {
      request += ','
    }
  })
  request += ' ] }'
  
  return $.ajax({
    url: that.updateURL,
    type: 'POST',
    dataType: 'json',
    data: JSON.parse(request)
  });
}

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
  var chosenMultipleSelect = $btn.prev()
  var chosenMultipleChoices = chosenMultipleSelect.find('[id^="tutorial_multiple_types"].chosen-container > ul.chosen-choices')
  var chosenMultipleValue = chosenMultipleSelect.find('.chosen-select').val()
  var inputTextField = $btn.siblings('input.repeated-field')
  var inputTextValue = inputTextField.val()
  
  if (chosenMultipleChoices.length > 0 && chosenMultipleValue === null) {
    addErrorOnChange(chosenMultipleSelect, chosenMultipleChoices)
  }
  if (!inputTextValue.trim().length) {
    addErrorOnChange(inputTextField)
  }
};

DynamicTutorialField.prototype.addRemoveBtn = function(id) {
  var $btn = $('<a class="medium-button outline-button inline-button remove-btn h-34 min-w-80">Remove</a>');
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

var update_dropdown_attributes = function(form_id) {
  var multiple_select = $("#" + form_id).find('.tutorial-fields.add-tutorial').last()
                                        .find('.chosen-styled-select')
                                        .find("select")
  if (multiple_select.length === 0) {
    return
  }
  var old_id = multiple_select.attr('id').match(/\d+/)
  var new_id = old_id == null ? 1 : parseInt(old_id[0]) + 1
  multiple_select.attr({
    id: "tutorial_multiple_types_" + new_id + "_[types]",
    name: "tutorial_multiple_types_" + new_id + "[[types]][]",
    value: ""
  });
  multiple_select.trigger('chosen:updated')
}

var multiselectDropdownHandle = function() {
  $('.chosen-select').chosen({allow_single_deselect: true})
  $('.chosen-container').css({"width": ""})
  var added_dropdowns = $('.chosen-styled-select').last().find($("[id^='tutorial_multiple_types_']"))
  if (added_dropdowns.length > 1) {
    added_dropdowns.last().remove()
  }
  update_dropdown_attributes($('form').attr('id'))
}

DynamicTutorialField.prototype.addAnotherBtnListener = function() {
  var that = this;
  $(document).on('click', this.addBtn, function() {
    var $btn = $(this);

    if (that.fieldIsEmpty($btn))
      that.submit($btn).success(function(data) {
        // Add hidden field with record id
        if ($('tr.tutorial-fields').length > 0) {
          $('<a data-id="' + data.id + '">').attr('type', 'hidden').appendTo($('tr.tutorial-fields td').last())
        } else if ($('.input-pair.tutorial-fields').length > 0) {
          $('<a data-id="' + data.id + '">').attr('type', 'hidden').appendTo($('.input-pair.tutorial-fields').last())
        }
        
        $btn.closest('.repeated-field').addClass('saved-field');
        that.addRow($btn, data.id);
        $('.tutorial-fields.add-tutorial').removeClass('add-tutorial')
        $('.tutorial-fields:last').addClass('add-tutorial')
        
        // In case of multiselect dropdown
        multiselectDropdownHandle()
      }).error(function(data) {
        that.showLittleError($btn);
      });
    else
      that.showLittleError($btn);
  });
};

DynamicTutorialField.prototype.submit = function($btn) {
  var that = this;
  var select_serialized = $('.collect-fields select').last().not('.saved-field').serialize()
  var input_serialized = $('.collect-fields input').not('.saved-field').serialize()
  var serialized_data = input_serialized + '&' + select_serialized

  return $.ajax({
    url: that.submitURL,
    type: 'POST',
    dataType: 'json',
    data: serialized_data
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
  var tutorialFields = $(".tutorial-fields.add-tutorial")[0]
  var textField = getTutorialInputTextField($(tutorialFields))
  var multipleSelect = getMultipleSelectField($(tutorialFields))
  var multipleSelectValue = getMultipleSelectValue(multipleSelect)
  var name = textField.val()

  if (name.trim().length > 0 || (multipleSelect.length > 0 && multipleSelectValue !== null)) {
    ev.preventDefault();
    $('.unsaved-changes-modal').click();
  };
};

DynamicTutorialField.prototype.listenUnsavedChanges = function() {
  var that = this
  that.modalSettings();
  
  $(".skip-and-continue").on("click", function() {
    $('.collect-fields input.repeated-field').val('');
    $(".modal, .modal-overlay").fadeOut(500, function() {
      $(".modal-overlay").remove();
      $('form').unbind('submit').submit()
    });
  });

  $(".save-and-continue").on("click", function() {
    $(".modal, .modal-overlay").fadeOut(500, function() {
      if ($(".modal-overlay").length == 1 ) {
        $(".modal-overlay").remove();
        if (FieldsValidate()) {
          that.updateAll()
          $("form").unbind('submit').submit()
        }
      }
    });
  });

  $('.skip-btn').on('click', this.dialogBehaviour);
};

DynamicTutorialField.prototype.modalSettings = function() {
  $(function() {
    var appendthis =  ("<div class='modal-overlay js-modal-close'></div>");
    $('button[data-modal-id]').click(function(e) {
      modalScreenShift($('#wizard-modal'))
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
    var update = ''
    if (tutorial_fields.hasClass('property-fields')) {
      create = "/financial_information/property/add_property";
      destroy = "/financial_information/property/";
      update = "/financial_information/property/update_all";
    } else if (tutorial_fields.hasClass('account-fields')) {
      create = "/financial_information/account/add_account";
      destroy = "/financial_information/account/provider/";
      update = "/financial_information/account/update_all"
    } else if (tutorial_fields.hasClass('investment-fields')) {
      create = "/financial_information/investment/add_investment";
      destroy = "/financial_information/investment/";
      update = "/financial_information/investment/update_all"
    } else if (tutorial_fields.hasClass('alternative-fields')) {
      create = "/financial_information/alternative/add_alternative";
      destroy = "/financial_information/alternative/provider/";
      update = "/financial_information/alternative/update_all"
    } else if (tutorial_fields.hasClass('trust-fields')) {
      create = "/trusts/";
      destroy = "/trusts/";
      update = "/trusts/update_all";
    } else if (tutorial_fields.hasClass('entity-fields')) {
      create = "/entities/";
      destroy = "/entities/";
      update = "/entities/update_all";
    } else if (tutorial_fields.hasClass('health-fields')) {
      create = "/insurance/healths";
      destroy = "/insurance/healths/provider/";
      update = "/insurance/healths/update_all";
    } else if (tutorial_fields.hasClass('property-casualty-fields')) {
      create = "/insurance/properties";
      destroy = "/insurance/properties/provider/";
      update = "/insurance/properties/update_all";
    } else if (tutorial_fields.hasClass('life-disability-fields')) {
      create = "/insurance/lives";
      destroy = "/insurance/lives/provider/";
      update = "/insurance/lives/update_all";
    }

    var tutorial = new DynamicTutorialField(create, destroy, update);

    $('.remove-btn').each(function(){ tutorial.removeBtnListener($(this)) })
    $("input[type='submit']").on('click', function(){ tutorial.updateAll() })
    
    $("form").on('submit', function(e) {
      e.preventDefault()
      if (FieldsValidate()) {
        $("form").unbind('submit').submit()
      }
    })
  }
  
  // Subtutorials with ajax-page (some action only)
  var ajax_page_checkboxes = $('input[class*="ajax-page"]')
  var edit_form = $('form[id*="edit_tutorial"]')
  if (ajax_page_checkboxes.length > 0 && edit_form.length > 0) {
    edit_form.submit(function(e) {
    var checkboxes = $('input[class*="ajax-page"]:checked')
    if (checkboxes.length > 0) {
        var thisForm = this
        e.preventDefault()
        var ids_chosen = []
        for (var i = 0; i < checkboxes.length; i++) {
          ids_chosen.push(checkboxes[i].className.match(/ajax-page-\d+/)[0].match(/\d+/)[0])
        }

        var ajax_page_handle_path = $('#ajax_page_handle_path').val()
        $.post(ajax_page_handle_path, {subtutorial_ids: ids_chosen})
          .done(function(data) {
            thisForm.submit()
          })
          .fail(function(data) {
            $(".flash-error").text(data.responseJSON.errors)
            $(".flash-error").show().fadeOut( 5000 );
          })
      }
    })
  }
});
