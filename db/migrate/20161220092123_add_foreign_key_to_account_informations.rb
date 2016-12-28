class AddForeignKeyToAccountInformations < ActiveRecord::Migration
  def change
    remove_column :financial_account_providers, :account_information_id
    add_column :financial_account_informations, :account_provider_id, :integer
  end
end
