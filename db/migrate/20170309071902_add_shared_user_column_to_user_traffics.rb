class AddSharedUserColumnToUserTraffics < ActiveRecord::Migration
  def change
    add_column :user_traffics, :shared_user_id, :integer
    add_index :user_traffics, :shared_user_id
    add_foreign_key :user_traffics, :users, column: :shared_user_id
  end
end
