class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}

  validates :user_id, presence: true
  has_many :vendors, dependent: :nullify
  has_many :shares, dependent: :destroy
  belongs_to :user_profile

  validates :emailaddress, presence: { :message => "Required" }
  validates_uniqueness_of :emailaddress, :scope => [:user_id, :emailaddress], allow_blank: true, message: "Email Address already taken"
  validates :emailaddress, :email_format => { :message => "Email should contain @ and domain like .com" }
  validate :email_is_valid?


  validates_length_of :firstname, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :lastname, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :emailaddress, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :beneficiarytype, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :address, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zipcode, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)

  validates_length_of :businessname, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :businesswebaddress, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :business_street_address_1, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :business_street_address_2, :maximum => ApplicationController.helpers.get_max_length(:default)

  validates_format_of :businesswebaddress,
                      :with => Validation::WEB_ADDRESS_URL,
                      :message => "Please enter a valid url (starts with 'http://' or 'https://')",
                      :allow_blank => true

  RELATIONSHIP_TYPES = {
    personal: [
      'Spouse / Domestic Partner',
      'Child',
      'Parent',
      'Grandparent',
      'Sibling',
      'Friend',
      'Other'
    ],
    professional: [
      'Accountant',
      'Attorney',
      'Financial Advisor / Broker',
      'Insurance Agent / Broker',
      'Commercial Banker',
      'Trustee',
      'Consultant',
      'Caregiver',
      'Advisor',
      'Other'
    ],
    medical_professional: %w(Doctor Nurse Administrator Caregiver Other),
    account_owner: ['Account Owner']
  }

  CONTACT_TYPES = {
    'Family & Beneficiaries' => RELATIONSHIP_TYPES[:personal],
    'Advisor' => RELATIONSHIP_TYPES[:professional],
    'Medical Professional' => RELATIONSHIP_TYPES[:medical_professional]
  }

  def email_is_valid?
    MailService.email_is_valid?(emailaddress, errors, :emailaddress)
  end

  def canonical_user
    User.find_by(email: emailaddress)
  end

  def personal_relationship?
    relationship.in? RELATIONSHIP_TYPES[:personal]
  end

  def professional_relationship?
    relationship.in? RELATIONSHIP_TYPES[:professional]
  end

  def medical_relationship?
    relationship.in? RELATIONSHIP_TYPES[:medical_professional]
  end

  def initials
    [firstname, lastname].compact.map(&:first).join
  end

  def account_owner?(resource_owner)
    (relationship.eql? 'Account Owner') &&
      (emailaddress.downcase.eql? resource_owner.email.downcase)
  end

  def name(biblio = false)
    if biblio
      [lastname,firstname].compact.join(', ')
    else
      [firstname,lastname].compact.join(' ')
    end
  end

  validate  :validate_contact_type_and_relationship
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }

  def validate_contact_type_and_relationship
    if contact_type.blank?
      return if relationship.blank? || RELATIONSHIP_TYPES[:account_owner].include?(relationship)
      self.errors[:relationship] << "is invalid for blank contact_type"
    elsif !CONTACT_TYPES.key?(contact_type)
      self.errors[:contact_type] << "must be in #{CONTACT_TYPES.keys}"
    elsif !CONTACT_TYPES[contact_type].include?(relationship)
      self.errors[:relationship] << "is invalid for contact_type #{contact_type}"
    end
  end
end
