class FinalWishInfo < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  belongs_to :category
  has_many :final_wishes, class_name: "FinalWish", foreign_key: :final_wish_info_id

  accepts_nested_attributes_for :final_wishes
  before_save { self.category = Category.fetch("final wishes") }
end
