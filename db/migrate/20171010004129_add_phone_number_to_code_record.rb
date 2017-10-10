class AddPhoneNumberToCodeRecord < ActiveRecord::Migration
  def change
    add_column :multifactor_phone_codes, :phone_number, :string
  end
end
