class AddUserToTaxYearInfos < ActiveRecord::Migration
  def change
    add_reference :tax_year_infos, :user, index: true, foreign_key: true
  end
end
