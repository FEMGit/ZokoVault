class FinalWishInfo < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  has_many :final_wishes, class_name: "FinalWish", foreign_key: :final_wish_info_id

  accepts_nested_attributes_for :final_wishes
end
