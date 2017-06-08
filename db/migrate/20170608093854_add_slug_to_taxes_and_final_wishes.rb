class AddSlugToTaxesAndFinalWishes < ActiveRecord::Migration
  def change
    unless column_exists? :taxes, :slug
      add_column :taxes, :slug, :string, :unique => true
      Tax.reset_column_information
    end
    
    unless column_exists? :tax_year_infos, :slug
      add_column :tax_year_infos, :slug, :string, :unique => true
      TaxYearInfo.reset_column_information
    end
    
    unless column_exists? :final_wishes, :slug
      add_column :final_wishes, :slug, :string, :unique => true
      FinalWish.reset_column_information
    end
    
    unless column_exists? :final_wish_infos, :slug
      add_column :final_wish_infos, :slug, :string, :unique => true
      FinalWishInfo.reset_column_information
    end
  end
end
