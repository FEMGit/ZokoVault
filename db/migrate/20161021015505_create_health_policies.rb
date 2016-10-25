class CreateHealthPolicies < ActiveRecord::Migration
  def change
    create_table :health_policies do |t|
      t.integer :policy_type
      t.string :policy_number
      t.string :group_number
      t.integer :policy_holder_id
      t.integer :broker_or_primary_contact_id
      t.string :notes
      t.integer :vendor_id

      t.timestamps null: false
    end
  end
end
