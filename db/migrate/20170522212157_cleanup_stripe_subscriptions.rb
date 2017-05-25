class CleanupStripeSubscriptions < ActiveRecord::Migration
  def change
    if column_exists? :stripe_subscriptions, :last4
      remove_column :stripe_subscriptions, :last4
    end
    
    if column_exists? :stripe_subscriptions, :name_on_card
      remove_column :stripe_subscriptions, :name_on_card
    end
    
    if column_exists? :stripe_subscriptions, :stripe_token
      remove_column :stripe_subscriptions, :stripe_token
    end

    unless index_exists? :stripe_subscriptions, :user_id
      add_index :stripe_subscriptions, :user_id
    end

    StripeSubscription.includes(:user).all.each do |sub|
      if sub.user.present? && sub.user.stripe_customer_record.blank?
        if sub.customer_id.present? && (sub.customer rescue nil).present?
          sub.user.create_stripe_customer_record(
            user_id: sub.user.id, stripe_customer_id: sub.customer.id)
        end
      end
    end

  end
end
