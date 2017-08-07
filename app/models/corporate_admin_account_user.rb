class CorporateAdminAccountUser < ActiveRecord::Base
  @@employee_type = "Employee".freeze
  @@client_type = "Client".freeze
  
  belongs_to :corporate_admin, :class_name => 'User'
  belongs_to :user_account, :class_name => 'User'
  
  enum account_type: [ @@employee_type, @@client_type ]
  
  def self.client_type
    @@client_type
  end
  
  def self.employee_type
    @@employee_type
  end
end
