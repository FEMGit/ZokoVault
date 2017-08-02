class AddAccountTypeToCorporateAdminAccountUsers < ActiveRecord::Migration
  def change
    add_column :corporate_admin_account_users, :account_type, :integer
    CorporateAdminAccountUser.reset_column_information
    CorporateAdminAccountUser.update_all(:account_type => CorporateAdminAccountUser::account_types["Client"])
  end
end
