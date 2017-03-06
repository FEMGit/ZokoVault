class DeleteSkipPhoneAuthentication < ActiveRecord::Migration
  def change
    remove_column :user_profiles, :phone_authentication_skip
  end
end
