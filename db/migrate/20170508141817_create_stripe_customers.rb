class CreateStripeCustomers < ActiveRecord::Migration
  def change
    create_table :stripe_customers, id: false do |t|
      t.integer :user_id, null: false
      t.string  :stripe_customer_id, null: false
    end
    add_index :stripe_customers, :user_id, unique: true
    add_index :stripe_customers, :stripe_customer_id, unique: true
  end
end
