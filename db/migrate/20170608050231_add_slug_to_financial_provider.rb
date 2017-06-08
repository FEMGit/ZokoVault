class AddSlugToFinancialProvider < ActiveRecord::Migration
  def change
    unless column_exists? :financial_providers, :slug
      add_column :financial_providers, :slug, :string, :unique => true
      FinancialProvider.reset_column_information
    end
  end
end
