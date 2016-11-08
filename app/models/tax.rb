class Tax < ActiveRecord::Base
<<<<<<< 82c88b35ea829336c1c8ee7db991e4e11f98cf18
  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :user
  belongs_to :document
  belongs_to :tax_preparer, class_name: "Contact"

  has_many :shares, as: :shareable, dependent: :destroy
  
  has_many :share_with_contacts, through: :shares, source: :contact
=======
>>>>>>> Ad-379 - details tax card
end
