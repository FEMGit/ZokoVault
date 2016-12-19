class ChangeNameForPrimaryContact < ActiveRecord::Migration
  def change
    rename_column :financial_account_providers, :primary_contact, :primary_contact_id
  end
end
