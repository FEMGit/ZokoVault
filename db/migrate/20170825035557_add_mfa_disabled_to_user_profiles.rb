class AddMfaDisabledToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :mfa_disabled, :boolean, :default => false, :null => false
  end
end
