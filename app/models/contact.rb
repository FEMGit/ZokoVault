class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}

  validates :firstname, presence: true
  validates :user_id, presence: true

  def name(biblio = false)
    if biblio
      [firstname,lastname].compact.join(' ')
    else
      [lastname,firstname].compact.join(', ')
    end
  end
end
