class AddCategoryRelationshipToResources < ActiveRecord::Migration
  def change
    add_column :wills, :category_id, :integer
    add_index  :wills, :category_id
    add_column :trusts, :category_id, :integer
    add_index  :trusts, :category_id
    add_column :power_of_attorneys, :category_id, :integer
    add_index  :power_of_attorneys, :category_id
    add_column :vendors, :category_id, :integer
    add_index  :vendors, :category_id
    add_column :taxes, :category_id, :integer
    add_index  :taxes, :category_id
    add_column :final_wishes, :category_id, :integer
    add_index  :final_wishes, :category_id
  end
end
