class Vendor < ActiveRecord::Base
  scope :for_user, ->(user) {where(user: user)}

  belongs_to :contact
  belongs_to :user

  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact
  has_many :documents, class_name: "Document", foreign_key: :vendor_id

  has_many :vendor_accounts, dependent: :destroy

  accepts_nested_attributes_for :vendor_accounts

  validates :name, presence: { :message => "Required" }

  after_initialize :initialize_category_and_group
  before_validation :build_shares

  def share_with_ids
    @share_with_ids || shares.map(&:ids)
  end

  attr_writer :share_with_ids

  private 

  def initialize_category_and_group
    # subclasses should initialize values
  end

  def build_shares
    shares.clear
    share_with_ids.map(&:present?).each do |contact_id|
      shares.build(user_id: user_id, contact_id: contact_id)
    end
  end
end
