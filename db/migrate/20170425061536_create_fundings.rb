class CreateFundings < ActiveRecord::Migration
  def change
    create_table :fundings do |t|
      t.references :user_subscription, index: true, foreign_key: true
      t.string     :type, null: false
      t.jsonb      :details, null: false
      t.timestamps null: false
    end
  end
end
