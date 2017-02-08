class AddAccountNameForFinancialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_account_informations, :name, :string
  end
end
