class CreateWills < ActiveRecord::Migration
  def change
    create_table :wills do |t|
      t.integer :document_id
      t.integer :executor_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
