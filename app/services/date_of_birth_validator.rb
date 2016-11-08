class DateOfBirthValidator < ActiveModel::Validator
  def validate(record)
    if record.date_of_birth.blank?
      record.errors['Date of Birth'] << "Date of Birth can't be blank"
    elsif (record.date_of_birth.to_date + 13.years) >= Date.today
      record.errors['Date of Birth'] << %(You must be 13 years or older to use ZokuVault. Please refer to our <a href='/terms-of-service' class="no-underline-link">Terms of Service</a> and for further details.)
    end
  end
end
