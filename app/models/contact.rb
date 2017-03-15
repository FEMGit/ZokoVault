class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}

  validates :user_id, presence: true
  has_many :vendors, dependent: :nullify
  has_many :shares, dependent: :destroy
  belongs_to :user_profile

  validates :emailaddress, presence: { :message => "Required" }
  validates_uniqueness_of :emailaddress, :scope => [:user_id, :emailaddress], allow_blank: true, message: "Email Address already taken"

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

  RELATIONSHIP_TYPES = {
    personal: [
      'Son',
      'Daughter',
      'Sibling',
      'Spouse/Domestic Partner',
      'Parent',
      'Grandparent',
      'Friend',
      'Other'
    ],
    professional: [
      'Accountant',
      'Attorney',
      'Financial Advisor / Broker',
      'Insurance Agent',
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
    'Medical Professional' => RELATIONSHIP_TYPES[:professional]
  }
  
  def email_is_valid?
    unless emailaddress =~ MailService.mail_regexp && check_domain(emailaddress)
      errors.add(:emailaddress, "Email should contain @ and domain like '.com")
    end
  end
  
  def check_domain(email)
    email_domain = MailService.email_domain(email)
    if EmailDomains::DOMAINS.any? { |dom| email_domain =~ dom }
      return true
    end
    false
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

  def name(biblio = false)
    if biblio
      [lastname,firstname].compact.join(', ')
    else
      [firstname,lastname].compact.join(' ')
    end
  end
  
  validates :relationship, inclusion: { in: RELATIONSHIP_TYPES.values.flatten, allow_blank: true }
  validates :contact_type, inclusion: { in: CONTACT_TYPES.keys.flatten, allow_blank: true }
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
end
