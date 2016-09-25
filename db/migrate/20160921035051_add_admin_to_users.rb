class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean

    User.update_all(admin: true)
  end
end
