class FinancialProperty < ActiveRecord::Base
  enum property_type: ["House",
                       "Land",
                       "Commercial",
                       "Vehicle",
                       "Jewelry",
                       "Artwork",
                       "Furniture",
                       "Antiquity",
                       "Heirloom",
                       "Valuable",
                       "Other Property"]

  scope :for_user, ->(user) { where(user: user) }
  scope :properties, ->(user) { where(user: user, property_type: FinancialInformation::PROPERTIES) }
  
  belongs_to :user
  belongs_to :primary_contact, class_name: "Contact"
  belongs_to :owner, class_name: "Contact"
  
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact
  
  validates :name, presence: { :message => "Required"}
end
