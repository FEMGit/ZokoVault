class ChangeTypeOfPropertyType < ActiveRecord::Migration
  def change
    change_column :financial_properties, :property_type, 'integer USING CAST(property_type AS integer)'
  end
end
