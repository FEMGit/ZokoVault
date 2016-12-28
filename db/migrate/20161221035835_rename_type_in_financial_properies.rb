class RenameTypeInFinancialProperies < ActiveRecord::Migration
  def change
    rename_column :financial_properties, :type, :property_type
  end
end
