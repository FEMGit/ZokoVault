class CreateCorporateEmployeeProfileTable < ActiveRecord::Migration
  def change
    create_table :corporate_employee_profiles do |t|
      t.references :corporate_employee
      t.string :contact_type
      t.string :relationship
    end

    add_index :corporate_employee_profiles, :corporate_employee_id
  end
end
