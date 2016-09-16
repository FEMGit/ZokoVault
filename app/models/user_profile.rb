class UserProfile < ActiveRecord::Base
  belongs_to :user

  has_many :security_questions,
    class_name: 'UserProfileSecurityQuestion'

  accepts_nested_attributes_for :security_questions

  attr_accessor :phone_code

  enum mfa_frequency: [:never, :new_device, :everytime]

  def name
    "#{first_name} #{last_name}"
  end

  def signed_terms_of_service?
    !!signed_terms_of_service_at
  end

  def phone_number_raw=(phone_number)
    self.phone_number = phone_number.gsub(/[^0-9]/, '')
  end

  def phone_number_formatted
    "#{phone_number[0..2]}-#{phone_number[3..5]}-#{phone_number[6..10]}"
  end

  def signed_terms_of_service=(val)
    self.signed_terms_of_service_at = Time.now if val
  end
end
