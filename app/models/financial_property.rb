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
  belongs_to :category
  belongs_to :primary_contact, class_name: "Contact"
  belongs_to :owner, class_name: "Contact"
  
  belongs_to :financial_provider, dependent: :destroy
  
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :documents, class_name: "Document", foreign_key: :financial_information_id, dependent: :nullify
  
  validates :name, presence: { :message => "Required"}
  before_save { self.category = Category.fetch("financial information") }
  
  validates :property_type, inclusion: { in: FinancialProperty::property_types }
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }

  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  validates_length_of :value, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :address, :maximum => ApplicationController.helpers.get_max_length(:default)
end
