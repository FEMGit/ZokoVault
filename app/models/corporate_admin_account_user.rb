class CorporateAdminAccountUser < ActiveRecord::Base
  EMPLOYEE_TYPE = "Employee".freeze
  CLIENT_TYPE   = "Client".freeze

  belongs_to :corporate_admin, class_name: 'User', inverse_of: :corporate_client_joins
  belongs_to :user_account, class_name: 'User', inverse_of: :corporate_provider_join

  enum account_type: [ EMPLOYEE_TYPE, CLIENT_TYPE ]

  def self.client_type
    CLIENT_TYPE
  end

  def self.employee_type
    EMPLOYEE_TYPE
  end

  def client?
    account_type == CLIENT_TYPE
  end

  def employee?
    account_type == EMPLOYEE_TYPE
  end
end
