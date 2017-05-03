class RenameSubscriptionsToStripeSubscriptions < ActiveRecord::Migration
  def change
    rename_table :subscriptions, :stripe_subscriptions
  end
end
