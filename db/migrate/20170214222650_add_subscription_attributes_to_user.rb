class AddSubscriptionAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string
    add_column :users, :subscription_status, :string, default: "unpaid"
    add_column :users, :subscription_type, :string
    add_column :users, :paid_through, :datetime
    add_column :users, :auto_resubscribe, :boolean, default: true
  end
end
