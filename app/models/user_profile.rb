class UserProfile < ActiveRecord::Base
  validates_with DateOfBirthValidator, fields: [:date_of_birth]
  scope :for_user, ->(user) { where(user: user).first }
 
  validates :email, :email_format => { :message => "Email should contain @ and domain like .com" }, on: :update
  validate :email_is_valid?, on: :update

  belongs_to :user
  has_many :employers
  has_one :contact, autosave: true

  has_many :security_questions,
    class_name: 'UserProfileSecurityQuestion'
  
  has_many :shares, as: :shareable, dependent: :destroy
  
  has_many :full_primary_shared_with,
    class_name: "Contact",
    foreign_key: "full_primary_shared_id"
  
  has_many :primary_shared_with, 
    through: :shares,
    source: :contact

  delegate :email, :email=, to: :user
  delegate :photourl, :photourl=, to: :contact, allow_nil: true
  delegate :password, :password=, to: :user
  delegate :password_confirmation, :password_confirmation=, to: :user
  
  accepts_nested_attributes_for :security_questions
  accepts_nested_attributes_for :employers

  attr_accessor :phone_code, :share_ids

  enum mfa_frequency: [:never, :new_ip, :always]

  validates_format_of :phone_number,
    with: /\A\d{3}-\d{3}-\d{4}\z/,
    allow_blank: true,
    message: "must be in format 222-555-1111"

  validates_format_of :phone_number_mobile,
    with: /\A\d{3}-\d{3}-\d{4}\z/,
    allow_blank: true,
    message: "must be in format 222-555-1111"
  
  validates_format_of :two_factor_phone_number,
    with: /\A\d{3}-\d{3}-\d{4}\z/,
    allow_blank: true,
    message: "must be in format 222-555-1111"
  
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
  
  validates_length_of :first_name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :middle_name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :last_name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :street_address_1, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  validates :first_name, :presence => { :message => "Required" }
  validates :last_name, :presence => { :message => "Required" }
  
  after_save :create_or_update_contact_card

  def name
    "#{first_name} #{last_name}"
  end
  
  def full_name
    "#{first_name} #{middle_name} #{last_name}"
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
    self.phone_number_mobile = format_phone_number(raw_phone_number)
  end

  def phone_number_formatted
    phone_number_mobile
  end

  def signed_terms_of_service=(val)
    self.signed_terms_of_service_at = Time.now if val
  end
  
  def mfa_never?
    self.mfa_frequency == "never"
  end
  
  def mfa_always?
    self.mfa_frequency == "always"
  end
  
  def mfa_new_ip?
    self.mfa_frequency == "new_ip"
  end
  
  private
  
  def email_is_valid?
    MailService.email_is_valid?(email, errors, :email)
  end

  def format_phone_number(raw_phone_number)
    tmp = raw_phone_number.gsub(/[^0-9]/, '')
    "#{tmp[0..2]}-#{tmp[3..5]}-#{tmp[6..10]}"
  end

  def create_or_update_contact_card
    contact = Contact.for_user(user).find_or_initialize_by(emailaddress: email)
    contact.update(
      firstname: first_name,
      lastname: last_name,
      emailaddress: user.email,
      phone: two_factor_phone_number,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      ssn: ssn,
      birthdate: date_of_birth,
      address: [street_address_1, street_address_2].compact.join(" "),
      zipcode: zip,
      state: state,
      user_id: user_id,
      city: city,
      user_profile_id: id
    )
  end
  
  after_update do
    primary_shared_with.each do |contact|
      ShareInvitationService.send_invitation(user, contact)
    end
  end
end
