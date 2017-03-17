class CreateUserTrafficTable < ActiveRecord::Migration
  def change
    create_table :user_traffics do |t|
      t.string :page_name
      t.string :page_url
      t.string :ip_address
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
