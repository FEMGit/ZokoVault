class AddIndexToWillsTrusts < ActiveRecord::Migration
  def change
    add_index :wills, :user_id
    add_index :trusts, :user_id
  end
end
