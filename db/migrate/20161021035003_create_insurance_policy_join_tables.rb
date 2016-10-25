class CreateInsurancePolicyJoinTables < ActiveRecord::Migration
  def change
    create_table :life_and_disability_policies_primary_beneficiaries do |t|
      t.integer :life_and_disability_policy_id
      t.integer :primary_beneficiary_id
    end

    create_table :life_and_disability_policies_secondary_beneficiaries do |t|
      t.integer :life_and_disability_policy_id
      t.integer :secondary_beneficiary_id
    end

    create_table :health_policies_insured_members do |t|
      t.integer :health_policy_id
      t.integer :insured_member_id
    end
  end
end
