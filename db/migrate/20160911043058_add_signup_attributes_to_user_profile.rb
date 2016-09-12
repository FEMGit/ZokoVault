class AddSignupAttributesToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :signed_terms_of_service_at, :datetime
    add_column :user_profiles, :phone_number, :string
    add_column :user_profiles, :mfa_frequency, :integer
  end
end
