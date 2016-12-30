class AddFinancialIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :financial_information_id, :integer
    add_index :documents, :financial_information_id
  end
end
