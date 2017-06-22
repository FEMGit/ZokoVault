class CorporateAdminAccountUser < ActiveRecord::Base
  belongs_to :corporate_admin, :class_name => 'User'
  belongs_to :user_account, :class_name => 'User'
end
