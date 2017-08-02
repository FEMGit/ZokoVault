class AddStripeCustomerIdToCorporateAccountProfiles < ActiveRecord::Migration
  def change
    add_column :corporate_account_profiles, :stripe_customer_id, :string
    add_index :corporate_account_profiles, :stripe_customer_id
  end
end
