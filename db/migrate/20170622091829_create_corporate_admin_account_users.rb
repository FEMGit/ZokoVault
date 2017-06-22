class CreateCorporateAdminAccountUsers < ActiveRecord::Migration
  def change
    create_table :corporate_admin_account_users, id: false do |t|
      t.references :corporate_admin
      t.references :user_account
      t.datetime :confirmation_sent_at
    end

    add_index :corporate_admin_account_users, :corporate_admin_id
    add_index :corporate_admin_account_users, :user_account_id
  end
end
