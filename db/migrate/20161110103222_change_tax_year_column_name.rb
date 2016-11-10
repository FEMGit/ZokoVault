class ChangeTaxYearColumnName < ActiveRecord::Migration
  def change
    rename_column :taxes, :tax_year, :tax_year_id
  end
end
