class CreateAccountOwnerTable < ActiveRecord::Migration
  def change
    create_table :account_policy_owners do |t|
      t.integer :contact_id
      t.integer :card_document_id
      t.integer :contactable_id
      t.string :contactable_type

      t.timestamps null: false
    end
  end
end
