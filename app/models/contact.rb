class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}

  validates :firstname, presence: true
  validates :user_id, presence: true
  has_many :vendors, dependent: :nullify
  has_many :shares, dependent: :destroy

  RELATIONSHIP_TYPES = {
    personal: [
      'Son',
      'Daughter',
      'Sibling',
      'Spouse/Domestic Partner',
      'Parent',
      'Grandparent',
      'Other Beneficiary',
    ],
    professional: [
      'Accountant',
      'Attorney',
      'Financial Advisor / Broker',
      'Insurance Agent',
      'Commercial Banker',
      'Trustee',
      'Broker',
    ],
    medical_professional: [
      'Accountant',
      'Attorney',
      'Financial Advisor / Broker',
      'Insurance Agent',
      'Commercial Banker',
      'Trustee',
      'Broker',
      "Doctor",
      "Nurse",
      "Administrator"
    ]
  }

  CONTACT_TYPES = {
    'Family & Beneficiaries' => RELATIONSHIP_TYPES[:personal],
    'Advisor' => RELATIONSHIP_TYPES[:professional],
    'Service Provider' => RELATIONSHIP_TYPES[:professional],
    'Medical Professional' => RELATIONSHIP_TYPES[:professional]
  }


  def personal_relationship?
    relationship.in? RELATIONSHIP_TYPES[:personal]
  end

  def professional_relationship?
    relationship.in? RELATIONSHIP_TYPES[:professional]
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
end
