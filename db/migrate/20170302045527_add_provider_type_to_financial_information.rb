class AddProviderTypeToFinancialInformation < ActiveRecord::Migration
  def change
    add_column :financial_providers, :provider_type, :integer
  end
end
