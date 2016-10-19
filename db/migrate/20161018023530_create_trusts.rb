class CreateTrusts < ActiveRecord::Migration
  def change
    create_table :trusts do |t|
      t.integer :document_id
      t.integer :executor_id
      t.string :name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
