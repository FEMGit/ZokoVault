class UserProfileSecurityQuestion < ActiveRecord::Base
  include SecurityQuestions
  belongs_to :user_profile
end
