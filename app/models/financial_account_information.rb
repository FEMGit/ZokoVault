class FinancialAccountInformation < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :slug_candidates
  
  def should_generate_new_friendly_id?
    name_changed? || account_type_changed? || ((name.present? || account_type.present?) && slug.blank?)
  end
  
  def slug_candidates
    [
      :name,
      [:name, :account_type]
    ]
  end
  
  enum account_type: ["Checking",
                      "Savings",
                      "Brokerage",
                      "Stock",
                      "Bond",
                      "Derivative",
                      "Government Security",
                      "Mutual Fund",
                      "IRA",
                      "Roth IRA",
                      "401K",
                      "403B",
                      "529",
                      "REIT",
                      "Credit Card",
                      "Mortgage",
                      "Auto Loan",
                      "Line of Credit",
                      "Business Loan",
                      "Student Loan",
                      "Undrawn Commitment"]
  has_many :account_owners, as: :contactable, dependent: :destroy, :class_name => 'AccountPolicyOwner'
  
  scope :for_user, ->(user) { where(user: user) }
  
  scope :cash, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_CASH) }
  scope :investments, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_INVESTMENTS) }
  scope :credit_cards, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_CREDIT_CARDS) }
  scope :loans, ->(user) { where(user: user, account_type: FinancialInformation::ACCOUNT_LOANS) }
  
  belongs_to :user
  belongs_to :category
  belongs_to :primary_contact_broker, class_name: "Contact"
  before_save { self.category = Category.fetch("financial information") }
  

  validates :account_type, inclusion: { in: FinancialAccountInformation::account_types }

  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  validates_length_of :number, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :value, :maximum => ApplicationController.helpers.get_max_length(:default)
end
