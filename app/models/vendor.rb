class Vendor < ActiveRecord::Base
  belongs_to :contact
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  has_many :vendor_accounts
end
