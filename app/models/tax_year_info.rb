class TaxYearInfo < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  belongs_to :category
  has_many :taxes, class_name: "Tax", foreign_key: :tax_year_id

  accepts_nested_attributes_for :taxes
  before_save { self.category = Category.fetch("taxes") }
  
  validates_length_of :year, :maximum => ApplicationController.helpers.get_max_length(:year)
end
