class AddCorporateAdminToUsersTable < ActiveRecord::Migration
  def change
    unless column_exists? :users, :corporate_admin
      add_column :users, :corporate_admin, :bool, :default => false
    end
  end
end
