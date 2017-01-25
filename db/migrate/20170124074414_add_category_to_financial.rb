class AddCategoryToFinancial < ActiveRecord::Migration
  def change
    add_column :financial_properties, :category_id, :integer
    add_index  :financial_properties, :category_id
    add_column :financial_investments, :category_id, :integer
    add_index  :financial_investments, :category_id
  end
end
