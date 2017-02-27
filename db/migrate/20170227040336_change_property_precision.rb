class ChangePropertyPrecision < ActiveRecord::Migration
  def change
    change_column :property_and_casualty_policies, :coverage_amount, :decimal, precision: 11, scale: 2
  end
end
