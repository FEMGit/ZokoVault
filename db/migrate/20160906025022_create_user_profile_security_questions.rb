class CreateUserProfileSecurityQuestions < ActiveRecord::Migration
  def change
    create_table :user_profile_security_questions do |t|
      t.references :user_profile
      t.string :question
      t.string :answer

      t.timestamps null: false
    end
  end
end
