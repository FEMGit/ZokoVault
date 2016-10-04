class CreateVaultEntryContacts < ActiveRecord::Migration
  def change
    create_table :vault_entry_contacts do |t|
      t.references :vault_entry, index: true, foreign_key: {on_delete: :cascade}
      t.integer :type
      t.boolean :active, default: true
      t.references :contact, index: true, foreign_key: {on_delete: :cascade}

      t.timestamps null: false
    end

    add_index :vault_entry_contacts, :type
  end
end
