class ChangeTypeOfAccountType < ActiveRecord::Migration
  def change
    change_column :financial_account_informations, :account_type, 'integer USING CAST(account_type AS integer)'
  end
end
