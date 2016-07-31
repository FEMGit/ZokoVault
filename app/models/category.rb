class Category < Folder
  scope :for_user, ->(user) {where(user: user)}
end
