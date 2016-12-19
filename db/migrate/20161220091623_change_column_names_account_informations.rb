class ChangeColumnNamesAccountInformations < ActiveRecord::Migration
  def change
    rename_column :financial_account_informations, :owner, :owner_id
    rename_column :financial_account_informations, :primary_contact_broker, :primary_contact_broker_id
  end
end
