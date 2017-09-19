class ToDoPopupCancel < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user).first }
  
  belongs_to :user
end
