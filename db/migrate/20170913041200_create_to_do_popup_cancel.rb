class CreateToDoPopupCancel < ActiveRecord::Migration
  def change
    create_table :to_do_popup_cancels do |t|
      t.references :user, index: true
      t.string :cancelled_popups, array: true, default: []
    end
  end
end
