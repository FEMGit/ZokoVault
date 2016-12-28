class ChangeNotesTypeFinancialInvestments < ActiveRecord::Migration
  def change
    change_column :financial_investments, :notes, :string
  end
end
