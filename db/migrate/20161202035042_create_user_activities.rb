class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities do |t|
      t.references :user, index: true, foreign_key: true
      t.date :login_date
      t.integer :login_count
      t.integer :session_length

      t.timestamps null: false
    end
  end
end
