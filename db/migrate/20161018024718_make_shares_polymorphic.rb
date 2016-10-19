class MakeSharesPolymorphic < ActiveRecord::Migration
  def change
    rename_column :shares, :vault_entry_id, :shareable_id
    add_column :shares, :shareable_type, :string
  end
end
