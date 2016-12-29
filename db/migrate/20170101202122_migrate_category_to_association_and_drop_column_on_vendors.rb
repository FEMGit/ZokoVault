class MigrateCategoryToAssociationAndDropColumnOnVendors < ActiveRecord::Migration
  def up
    Vendor.all.each do |vendor|
      next if vendor.category.blank?
      if (category = Category.fetch(vendor.category.downcase))
        vendor.update(category_id: category.id)
      end
    end

    remove_column :vendors, :category
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
