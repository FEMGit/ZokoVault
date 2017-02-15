class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :name_on_card
      t.string :last4
      t.string :customer_id
      t.string :stripe_token
      t.string :plan_id
      t.string :promo_code

      t.timestamps null: false
    end
  end
end
