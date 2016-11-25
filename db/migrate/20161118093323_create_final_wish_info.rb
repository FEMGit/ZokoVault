class CreateFinalWishInfo < ActiveRecord::Migration
  def change
    create_table :final_wish_infos do |t|
      t.string :group
      
      t.timestamps null: false
    end
  end
end
