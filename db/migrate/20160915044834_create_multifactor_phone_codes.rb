class CreateMultifactorPhoneCodes < ActiveRecord::Migration
  def change
    create_table :multifactor_phone_codes do |t|
      t.integer :user_id
      t.string :code

      t.timestamps null: false
    end

    add_index :multifactor_phone_codes, :user_id
  end
end
