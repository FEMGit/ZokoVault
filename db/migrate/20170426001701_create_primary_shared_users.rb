class CreatePrimarySharedUsers < ActiveRecord::Migration
  def change
    create_table :primary_shared_users, id: false do |t|
      t.integer :owning_user_id, null: false
      t.integer :shared_with_user_id, null: false
    end
    add_index :primary_shared_users, :owning_user_id, unique: true
    add_index :primary_shared_users, :shared_with_user_id
  end
end
