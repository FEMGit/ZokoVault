class FinancialProvider < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  scope :type, ->(type) { where(provider_type: type) }
  enum provider_type: [ "Account", "Investment", "Alternative", "Property"]
  
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
  before_save { self.category = Category.fetch("financial information") }
  
  before_validation :build_shares
  
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
  validates :provider_type, inclusion: { in: FinancialProvider::provider_types }

  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :web_address, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  validates_length_of :street_address, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  
  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids
  
  private
  
  def build_shares
    shares.clear
    share_with_contact_ids.select(&:present?).each do |contact_id|
      shares.build(user_id: user_id, contact_id: contact_id)
    end
  end
end
