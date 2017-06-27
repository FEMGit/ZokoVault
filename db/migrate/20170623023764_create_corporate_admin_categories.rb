class CreateCorporateAdminCategories < ActiveRecord::Migration
  def change
    create_table :corporate_admin_categories do |t|
      t.belongs_to :user, index: true
      t.belongs_to :category, index: true
    end
  end
end
