class RemovePrimaryCompanyStockTutorial < ActiveRecord::Migration
  def change
    Tutorial.where(name: 'Private Company Stock').destroy_all
  end
end
