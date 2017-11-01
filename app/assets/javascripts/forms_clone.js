changeIdAndName = function($form, old_id, new_id, new_name){
  $form.find("#" + old_id).attr({
    id: new_id,
    name: new_name,
    value: ""
  });
  $form.find("#" + new_id + " option").prop("selected", false).trigger('chosen:updated');
  unselectItemsByClass(new_id, $form, ".contact-item")
  unselectItemsByClass(new_id, $form, ".owner-item")
};


unselectItemsByClass = function(new_id, $form, class_selector) {
  $form.find("#" + new_id + class_selector).val("").trigger('chosen:updated');
}

updateMultipleDropdowns = function($form) {
  var newMultipleDropdowns = $form.find('.chosen-styled-select').find(".chosen-container-multi")
  for(var i = 0; i < newMultipleDropdowns.length; i++) {
    var multipleSelect = $(newMultipleDropdowns[i]).prev()
    multipleSelect.trigger('chosen:updated')
  }
}

changeHiddenMultipleSelect = function($form, old_name, new_name) {
  $form.find("[name=\'" + old_name + "\']").attr({
    name: new_name,
    value: ''
  });
};

updateShareEmailPreviewSection = function(form, new_name) {
  setEmailPreviewSingleDropdown($("#" + new_name), new_name)
  form.find("#email-preview-list").find("p").remove()
  form.find("#email-preview-list").removeClass().addClass(new_name)
}