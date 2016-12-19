class AddUserToFinancialAccounts < ActiveRecord::Migration
  def change
    add_reference :financial_account_informations, :user, index: true
    add_reference :financial_account_providers, :user, index: true
  end
end
