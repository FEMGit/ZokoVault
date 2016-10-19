class DropForeignKeyOnVaultEntryBeneficiaries < ActiveRecord::Migration
  def change
    remove_foreign_key :vault_entry_beneficiaries, name: "fk_rails_517208ddec"
  end
end
