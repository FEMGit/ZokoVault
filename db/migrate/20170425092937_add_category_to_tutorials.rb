class AddCategoryToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :category_id, :integer
    add_index  :tutorials, :category_id
    
    add_column :tutorials, :relative_page_path, :string
  end
end
