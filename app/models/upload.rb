class Upload < ActiveRecord::Base
   #mount_uploader :name, ImageUploader
   belongs_to :user
   
   scope :for_user, ->(user) {where(user: user)}
end
