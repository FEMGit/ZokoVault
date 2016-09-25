class CreateVaultEntryContacts < ActiveRecord::Migration
  def change
    create_table :vault_entry_contacts do |t|
      t.references :vault_entry, index: true, foreign_key: true
      t.integer :type
      t.boolean :active, default: true
      t.references :contact, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :vault_entry_contacts, :type
  end
end
