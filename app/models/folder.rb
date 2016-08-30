class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :documents

  acts_as_tree order: "name"

  scope :for_user, ->(user) {where(user: user)}

  scope :in_folder, ->(parent) {where(parent: parent)}
  scope :just_folders, -> {where(type: 'Folder')}
end
