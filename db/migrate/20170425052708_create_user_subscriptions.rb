class CreateUserSubscriptions < ActiveRecord::Migration
  def change
    create_table :user_subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.timestamp  :start_at, null: false
      t.timestamp  :end_at, null: false
      t.timestamps null: false
    end
  end
end
