class Upload < ActiveRecord::Base
   #mount_uploader :name, ImageUploader
   belongs_to :user
end
