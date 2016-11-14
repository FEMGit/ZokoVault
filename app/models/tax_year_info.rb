class TaxYearInfo < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  has_many :taxes, class_name: "Tax", foreign_key: :tax_year_id

  accepts_nested_attributes_for :taxes
end
