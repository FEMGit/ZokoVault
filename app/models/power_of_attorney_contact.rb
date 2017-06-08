class PowerOfAttorneyContact < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :poa_for_name
  
  def should_generate_new_friendly_id?
    contact_id_changed? || slug.blank?
  end
  
  def poa_for_name
    contact.try(:name)
  end

  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :contact
  belongs_to :user
  belongs_to :category
  
  has_many :power_of_attorneys, 
    class_name: "PowerOfAttorney",
    foreign_key: :power_of_attorney_id,
    dependent: :destroy
  
  has_many :shares, as: :shareable, dependent: :destroy
  
  has_many :share_with_contacts, 
    through: :shares,
    source: :contact
  
  before_save { self.category = Category.fetch("wills - poa") }
  before_validation :build_shares
  after_save :update_wills_poa
  after_destroy :delete_wills_poa
  
  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids
  
  private
  
  def build_shares
    if not_shared_mode?
      shares.clear
      share_with_contact_ids.select(&:present?).each do |contact_id|
        shares.build(user_id: user_id, contact_id: contact_id)
      end
    end
  end
  
  def not_shared_mode?
    Thread.current[:current_user].present? && user.present? &&
      Thread.current[:current_user] == user
  end
  
  def update_wills_poa
    wills_poa = CardDocument.find_or_initialize_by(card_id: self.id, object_type: 'PowerOfAttorneyContact')
    wills_poa.update(user_id: self.user_id, object_type: self.class, category: Category.fetch("wills - poa"))
  end
  
  def delete_wills_poa
    CardDocument.where(card_id: self.id, object_type: 'PowerOfAttorneyContact').destroy_all
  end
end