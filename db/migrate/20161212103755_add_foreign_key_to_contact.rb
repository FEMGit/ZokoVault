class AddForeignKeyToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :full_primary_shared_id, :integer
    add_index :contacts, :full_primary_shared_id
    add_foreign_key :contacts, :user_profiles, column: :full_primary_shared_id
  end
end
