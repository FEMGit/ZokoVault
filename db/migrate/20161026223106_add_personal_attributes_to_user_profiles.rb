class AddPersonalAttributesToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :ssn, :string
    add_column :user_profiles, :phone_number_mobile, :string
    add_column :user_profiles, :street_address_1, :string
    add_column :user_profiles, :street_address_2, :string
    add_column :user_profiles, :city, :string
    add_column :user_profiles, :state, :string
    add_column :user_profiles, :zip, :string
  end
end
