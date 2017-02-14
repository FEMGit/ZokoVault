class FinancialInvestment < ActiveRecord::Base
  enum investment_type: ["Private Company Stock", "Private Company Debt", "Royalty",
                         "IOU", "Other Investments", "Other Loans"]
  
  scope :investments, ->(user) { where(user: user, investment_type: FinancialInformation::INVESTMENTS) }
  scope :loans, ->(user) { where(user: user, investment_type: FinancialInformation::INVESTMENT_LOANS) }
  
  scope :for_user, ->(user) { where(user: user) }
  belongs_to :user
  belongs_to :category
  
  belongs_to :primary_contact, class_name: "Contact"
  belongs_to :owner, class_name: "Contact"
  
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :documents, class_name: "Document", foreign_key: :financial_information_id, dependent: :nullify
  
  validates :name, presence: { :message => "Required"}
  
  before_save { self.category = Category.fetch("financial information") }
  
  validates :investment_type, inclusion: { in: FinancialInvestment::investment_types }
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }

  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  validates_length_of :value, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :address, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :web_address, :maximum => ApplicationController.helpers.get_max_length(:default)
end
