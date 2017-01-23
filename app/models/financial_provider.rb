class FinancialProvider < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  belongs_to :user
  belongs_to :category
  belongs_to :primary_contact, class_name: "Contact"
  has_many :shares, as: :shareable, dependent: :destroy
  
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :accounts, 
           class_name: "FinancialAccountInformation",
           foreign_key: :account_provider_id,
           dependent: :destroy
  
  has_many :alternatives, 
           class_name: "FinancialAlternative",
           foreign_key: :manager_id,
           dependent: :destroy
  
  has_many :properties, 
           class_name: "FinancialProperty",
           foreign_key: :empty_provider_id,
           dependent: :destroy
  
  has_many :investments, 
           class_name: "FinancialInvestment",
           foreign_key: :empty_provider_id,
           dependent: :destroy
  
  has_many :documents, class_name: "Document", foreign_key: :financial_information_id, dependent: :nullify
  
  validates :name, presence: { :message => "Required" }
  before_save { self.category = Category.fetch("Financial Information") }
end
