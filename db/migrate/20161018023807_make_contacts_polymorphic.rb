class MakeContactsPolymorphic < ActiveRecord::Migration
  def change
    remove_column :vault_entry_contacts, :vault_entry_id
    add_column :vault_entry_contacts, :contactable_id, :integer
    add_column :vault_entry_contacts, :contactable_type, :string
  end
end
