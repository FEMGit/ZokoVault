class RenameFinancialAccountProvidersToFinancialProviders < ActiveRecord::Migration
  def change
    rename_table :financial_account_providers, :financial_providers
    add_column :financial_providers, :type, :string
  end
end
