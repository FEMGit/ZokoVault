class FinalWish < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :category
  belongs_to :document
  belongs_to :user
  belongs_to :primary_contact, class_name: "Contact"

  has_many :shares, as: :shareable, dependent: :destroy

  has_many :share_with_contacts, through: :shares, source: :contact

  before_save { self.category = Category.fetch("final wishes") }
  before_validation :build_shares

  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids
  
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  def build_shares
    shares.clear
    share_with_contact_ids.select(&:present?).each do |contact_id|
      shares.build(user_id: user_id, contact_id: contact_id)
    end
  end
end
