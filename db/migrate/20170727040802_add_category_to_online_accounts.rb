class AddCategoryToOnlineAccounts < ActiveRecord::Migration
  def change
    add_column :online_accounts, :category_id, :integer
    add_index :online_accounts, :category_id
  end
end
