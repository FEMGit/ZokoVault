class CreateUserDeathTraps < ActiveRecord::Migration
  def change
    create_table :user_death_traps do |t|
      t.references :user, index: true, foreign_key: true
      t.string :page_terminated_on
      t.string :error_message

      t.timestamps null: false
    end
  end
end
