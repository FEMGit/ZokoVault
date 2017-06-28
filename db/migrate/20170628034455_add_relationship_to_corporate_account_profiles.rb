class AddRelationshipToCorporateAccountProfiles < ActiveRecord::Migration
  def change
    add_column :corporate_account_profiles, :contact_type, :string
    add_column :corporate_account_profiles, :relationship, :string
  end
end
