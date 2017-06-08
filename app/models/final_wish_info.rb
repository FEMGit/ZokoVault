class FinalWishInfo < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :group
  
  def should_generate_new_friendly_id?
    group_changed? || slug.blank?
  end
  
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  belongs_to :category
  has_many :final_wishes, class_name: "FinalWish", foreign_key: :final_wish_info_id

  accepts_nested_attributes_for :final_wishes
  before_save { self.category = Category.fetch("final wishes") }
  
  validates_length_of :group, :maximum => ApplicationController.helpers.get_max_length(:default)
end
