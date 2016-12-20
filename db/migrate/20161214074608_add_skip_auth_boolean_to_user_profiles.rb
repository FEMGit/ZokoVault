class AddSkipAuthBooleanToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :phone_authentication, :boolean
  end
end
