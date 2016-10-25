class CreatePropertyAndCasualtyPolicies < ActiveRecord::Migration
  def change
    create_table :property_and_casualty_policies do |t|
      t.integer :policy_type
      t.string :insured_property
      t.integer :policy_holder_id
      t.decimal :coverage_amount, precision: 10, scale: 2
      t.string :policy_number
      t.integer :broker_or_primary_contact_id
      t.string :notes
      t.integer :vendor_id
      t.string :notes

      t.timestamps null: false
    end
  end
end
