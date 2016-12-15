class RemoveConstraintFromSalt < ActiveRecord::Migration
  def change
    change_column :old_passwords, :password_salt, :string, :null => true
  end
end
