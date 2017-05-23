class Vendor < ActiveRecord::Base
  scope :for_user, ->(user) {where(user: user)}

  belongs_to :category
  belongs_to :contact
  belongs_to :user

  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :documents, class_name: "Document", foreign_key: :vendor_id, dependent: :nullify

  has_many :vendor_accounts, dependent: :destroy

  accepts_nested_attributes_for :vendor_accounts

  validates :name, presence: { :message => "Required" }

  after_initialize :initialize_category_and_group
  before_validation :build_shares

  def share_with_ids
    @share_with_ids || shares.map(&:id)
  end

  attr_writer :share_with_ids
  
  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :webaddress, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  validates_length_of :street_address_1, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :city, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :zip, :maximum => ApplicationController.helpers.get_max_length(:zipcode)
  
  validates_format_of :webaddress,
                      :with => Validation::WEB_ADDRESS_URL,
                      :message => "Please enter a valid url (starts with 'http://' or 'https://')",
                      :allow_blank => true

  private 

  def initialize_category_and_group
    # subclasses should initialize values
  end

  def build_shares
    if not_shared_mode?
      shares.clear
      share_with_ids.select(&:present?).each do |contact_id|
        shares.build(user_id: user_id, contact_id: contact_id)
      end
    end
  end
  
  def not_shared_mode?
    Thread.current[:current_user].present? && user.present? &&
      Thread.current[:current_user] == user
  end
  
  def self.healths
    self.where(type: 'Health')
  end

  def self.properties
    self.where(type: 'PropertyAndCasualty')
  end

  def self.lives
    self.where(type: 'LifeAndDisability')
  end
  
  validates :state, inclusion: { in:  States::STATES.map(&:last), allow_blank: true }
end
