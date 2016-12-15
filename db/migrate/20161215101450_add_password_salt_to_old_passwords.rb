class AddPasswordSaltToOldPasswords < ActiveRecord::Migration
  def change
    add_column :old_passwords, :password_salt, :string, :null => false
  end
end
