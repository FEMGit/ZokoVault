class DateOfBirthValidator < ActiveModel::Validator
  def validate(record)
    if record.date_of_birth.present? && (record.date_of_birth.to_date + 13.years) >= Date.today
      record.errors['Date of Birth'] << %(You must be 13 years or older to use ZokuVault. Please refer to our <a href='/terms_of_service' class="no-underline-link">Terms of Service</a> for further details.)
    end
  end
end
