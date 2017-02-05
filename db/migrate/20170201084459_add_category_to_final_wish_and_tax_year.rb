class AddCategoryToFinalWishAndTaxYear < ActiveRecord::Migration
  def change
    unless column_exists? :final_wish_infos, :category_id
      add_column :final_wish_infos, :category_id, :integer
      add_index  :final_wish_infos, :category_id
    end
    unless column_exists? :tax_year_infos, :category_id
      add_column :tax_year_infos, :category_id, :integer
      add_index  :tax_year_infos, :category_id
    end
  end
end
