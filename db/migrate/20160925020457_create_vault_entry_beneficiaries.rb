class CreateVaultEntryBeneficiaries < ActiveRecord::Migration
  def change
    create_table :vault_entry_beneficiaries do |t|
      t.references :vault_entry, foreign_key: {on_delete: :cascade}
      t.boolean :active
      t.decimal :percentage
      t.integer :type
      t.references :contact, foreign_key: {on_delete: :cascade}

      t.timestamps null: false
    end

    add_index :vault_entry_beneficiaries, :vault_entry_id
    add_index :vault_entry_beneficiaries, :contact_id
  end
end
