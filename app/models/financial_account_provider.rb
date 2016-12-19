class FinancialAccountProvider < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  belongs_to :user
  belongs_to :primary_contact, class_name: "Contact"
  has_many :shares, as: :shareable, dependent: :destroy
  
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :accounts, 
           class_name: "FinancialAccountInformation",
           foreign_key: :account_provider_id
  
  validates :name, presence: { :message => "Required" }
end
