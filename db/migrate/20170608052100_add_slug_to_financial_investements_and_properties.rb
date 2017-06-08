class AddSlugToFinancialInvestementsAndProperties < ActiveRecord::Migration
  def change
    unless column_exists? :financial_alternatives, :slug
      add_column :financial_alternatives, :slug, :string, :unique => true
      FinancialAlternative.reset_column_information
    end
    
    unless column_exists? :financial_properties, :slug
      add_column :financial_properties, :slug, :string, :unique => true
      FinancialProperty.reset_column_information
    end
    
    unless column_exists? :financial_investments, :slug
      add_column :financial_investments, :slug, :string, :unique => true
      FinancialInvestment.reset_column_information
    end
  end
end
