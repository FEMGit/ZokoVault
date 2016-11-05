class AddNotesToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :notes, :string
  end
end
