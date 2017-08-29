class AddCorporateCreditCardRequiredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :corporate_credit_card_required, :boolean, :default => true
  end
end
