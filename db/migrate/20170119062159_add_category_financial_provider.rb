class AddCategoryFinancialProvider < ActiveRecord::Migration
  def change
    add_column :financial_providers, :category_id, :integer
    add_index  :financial_providers, :category_id
  end
end
