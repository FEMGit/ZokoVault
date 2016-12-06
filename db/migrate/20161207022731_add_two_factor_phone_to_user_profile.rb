class AddTwoFactorPhoneToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :two_factor_phone_number, :string
  end
end
