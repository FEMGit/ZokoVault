changeIdAndName = function($form, old_id, new_id, new_name){
  $form.find("#" + old_id).attr({
    id: new_id,
    name: new_name,
    value: ""
  });
  $form.find("#" + new_id + " option.contact-item").prop("selected", false).trigger('chosen:updated');
  $form.find("#" + new_id + ".contact-item").val("").trigger('chosen:updated');
};

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