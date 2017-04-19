class UpdateLifePolicySecondaryContactTable < ActiveRecord::Migration
  def change
    rename_column :life_and_disability_policies_secondary_beneficiaries, :secondary_beneficiary_id, :contact_id
    add_column :life_and_disability_policies_secondary_beneficiaries, :card_document_id, :integer
  end
end
