class AddUserReferenceToFinalWishInfos < ActiveRecord::Migration
  def change
    add_reference :final_wish_infos, :user, index: true, foreign_key: true
  end
end
