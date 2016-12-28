class AddUserToFinancialProperies < ActiveRecord::Migration
  def change
    add_reference :financial_properties, :user, index: true
  end
end
