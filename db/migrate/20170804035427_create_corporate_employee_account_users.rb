class CreateCorporateEmployeeAccountUsers < ActiveRecord::Migration
  def change
    create_table :corporate_employee_account_users do |t|
      t.references :corporate_employee
      t.references :user_account
    end

    add_index :corporate_employee_account_users, :corporate_employee_id
    add_index :corporate_employee_account_users, :user_account_id
  end
end
