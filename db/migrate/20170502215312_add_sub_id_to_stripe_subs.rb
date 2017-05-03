class AddSubIdToStripeSubs < ActiveRecord::Migration
  def change
    add_column :stripe_subscriptions, :subscription_id, :string
    add_index :stripe_subscriptions, :subscription_id
  end
end
