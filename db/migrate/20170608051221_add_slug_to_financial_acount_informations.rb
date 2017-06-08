class AddSlugToFinancialAcountInformations < ActiveRecord::Migration
  def change
    unless column_exists? :financial_account_informations, :slug
      add_column :financial_account_informations, :slug, :string, :unique => true
      FinancialAccountInformation.reset_column_information
    end
  end
end
