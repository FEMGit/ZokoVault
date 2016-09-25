class AddExtraBusinessAddress < ActiveRecord::Migration
  def change
    remove_column :contacts, :business_street_address, :string
    add_column :contacts, :business_street_address_1, :string
    add_column :contacts, :business_street_address_2, :string
  end
end
