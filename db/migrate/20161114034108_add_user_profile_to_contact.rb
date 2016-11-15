class AddUserProfileToContact < ActiveRecord::Migration
  def change
    add_reference :contacts, :user_profile, index: true
  end
end
