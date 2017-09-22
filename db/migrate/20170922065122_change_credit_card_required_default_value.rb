class ChangeCreditCardRequiredDefaultValue < ActiveRecord::Migration
  def change
    change_column_default :users, :corporate_credit_card_required, :false
  end
end
