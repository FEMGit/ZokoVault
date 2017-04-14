class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :user, index: true, foreign_key: true
      t.string :stripe_id
      t.string :description
      t.integer :amount
      t.string :currency
      t.boolean :captured
      t.timestamps null: false
    end
  end
end
