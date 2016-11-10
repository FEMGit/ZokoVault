class UserProfile < ActiveRecord::Base
  validates_with DateOfBirthValidator, fields: [:date_of_birth]
  
  belongs_to :user
  has_many :employers

  has_many :security_questions,
    class_name: 'UserProfileSecurityQuestion'

  delegate :email, :email=, to: :user

  accepts_nested_attributes_for :security_questions
  accepts_nested_attributes_for :employers

  attr_accessor :phone_code, :share_ids

  enum mfa_frequency: [:never, :new_ip, :always]

  validates_format_of :phone_number,
    with: /\d{3}-\d{3}-\d{4}/, 
    allow_blank: true, 
    message: "must be in format 222-555-1111"

  validates_format_of :phone_number_mobile, 
    with: /\d{3}-\d{3}-\d{4}/, 
    allow_blank: true, 
    message: "must be in format 222-555-1111"

  after_save :create_or_update_contact_card

  def name
    "#{first_name} #{last_name}"
  end
  
  def initials
    [first_name, last_name].compact.map(&:first).join
  end

  def signed_terms_of_service?
    !!signed_terms_of_service_at
  end

  def address_parts
    [
      "#{street_address_1} #{street_address_2}".strip,
      "#{city}, #{state} #{zip}".strip
    ]
  end

  def phone_number_raw=(raw_phone_number)
    self.phone_number = format_phone_number(raw_phone_number)
  end

  def phone_number_formatted
    phone_number
  end

  def signed_terms_of_service=(val)
    self.signed_terms_of_service_at = Time.now if val
  end

  private

  def format_phone_number(raw_phone_number)
    tmp = raw_phone_number.gsub(/[^0-9]/, '')
    "#{tmp[0..2]}-#{tmp[3..5]}-#{tmp[6..10]}"
  end

  def create_or_update_contact_card
    contact = Contact.for_user(user).find_or_initialize_by(emailaddress: email)
    contact.update_attributes(
      firstname: first_name,
      lastname: last_name,
      emailaddress: user.email,
      phone: phone_number,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      ssn: ssn,
      birthdate: date_of_birth,
      address: [street_address_1, street_address_2].compact.join(" "),
      zipcode: zip,
      state: state,
      user_id: user_id,
      city: city
    )
  end
end
