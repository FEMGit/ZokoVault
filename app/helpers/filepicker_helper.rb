module FilepickerHelper
  def file_picker_api_key
    Rails.application.secrets.filepicker_api_key
  end
end