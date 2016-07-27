class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  scope :for_user, ->(user) {where(user: user)}

  scope :in_folder, ->(folder) {where(folder: folder)}
end
