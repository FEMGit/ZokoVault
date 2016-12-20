class ChangeColumnNameUserProfiles < ActiveRecord::Migration
  def change
    rename_column :user_profiles, :phone_authentication, :phone_authentication_skip 
  end
end
