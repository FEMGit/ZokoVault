class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :documents

  acts_as_tree order: "name"

  scope :for_user, ->(user) {where(user: user)}

  scope :in_folder, ->(parent) {where(parent: parent)}
  scope :just_folders, -> {where(type: 'Folder')}

  def parent_path
    url_helpers = Rails.application.routes.url_helpers
    if (parent.instance_of? Category)
      url_helpers.category_path(parent)
    else
      url_helpers.folder_path(parent)
    end
  end
end
