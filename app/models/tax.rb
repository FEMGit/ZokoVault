class Tax < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :category
  belongs_to :user
  belongs_to :document
  belongs_to :tax_preparer, class_name: "Contact"

  has_many :shares, as: :shareable, dependent: :destroy
  has_many :share_with_contacts, through: :shares, source: :contact

  before_save { self.category = Category.fetch("taxes") }
  
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
end
