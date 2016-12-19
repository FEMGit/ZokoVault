class ChangeTypeNameInFinancialAccount < ActiveRecord::Migration
  def change
    rename_column :financial_account_informations, :type, :account_type
  end
end
