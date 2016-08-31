class Vendor < ActiveRecord::Base
  scope :for_user, ->(user) {where(user: user)}

  belongs_to :contact
  belongs_to :user

  has_many :vendor_accounts, dependent: :destroy

  accepts_nested_attributes_for :vendor_accounts

  validates :name, presence: true
end
