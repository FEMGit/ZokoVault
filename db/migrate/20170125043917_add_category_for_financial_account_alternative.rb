class AddCategoryForFinancialAccountAlternative < ActiveRecord::Migration
  def change
    add_column :financial_account_informations, :category_id, :integer
    add_index  :financial_account_informations, :category_id
    add_column :financial_alternatives, :category_id, :integer
    add_index  :financial_alternatives, :category_id
  end
end
