class CreateCurrentUserSubscriptionMarkers < ActiveRecord::Migration
  def change
    create_table :current_user_subscription_markers, id: false do |t|
      t.integer :user_id, null: false
      t.integer :user_subscription_id, null: false
    end
    add_index :current_user_subscription_markers, :user_id,
      unique: true, name: 'index_current_user_subscription_uid'
    add_index :current_user_subscription_markers, :user_subscription_id,
      unique: true, name: 'index_current_user_subscription_usid'
  end
end
