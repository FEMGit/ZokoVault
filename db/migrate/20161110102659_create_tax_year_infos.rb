class CreateTaxYearInfos < ActiveRecord::Migration
  def change
    create_table :tax_year_infos do |t|
      t.integer :year

      t.timestamps null: false
    end
  end
end
