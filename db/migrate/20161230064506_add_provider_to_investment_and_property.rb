class AddProviderToInvestmentAndProperty < ActiveRecord::Migration
  def change
    add_column :financial_investments, :empty_provider_id, :integer
    add_column :financial_properties, :empty_provider_id, :integer
  end
end
