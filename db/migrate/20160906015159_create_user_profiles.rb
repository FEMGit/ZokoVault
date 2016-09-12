class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.references :user
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :date_of_birth

      t.timestamps null: false
    end
  end
end
