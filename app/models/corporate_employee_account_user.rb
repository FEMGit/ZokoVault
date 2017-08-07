class CorporateEmployeeAccountUser < ActiveRecord::Base
  belongs_to :corporate_employee, :class_name => 'User'
  belongs_to :user_account, :class_name => 'User'
end
