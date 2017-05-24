class AddCategorySubcategoryCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :category_count, :integer
    add_column :users, :subcategory_count, :integer
    
    UserService.update_categories_count
    UserService.update_subcategories_count
  end
end
