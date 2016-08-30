class Category < Folder
  scope :for_user, ->(user) {where(user: user)}

  validates :name, presence: true
end
