class MailchimpUsersCleanup < ActiveRecord::Migration
  def change
    mailchimp_service = MailchimpService.new
    mailchimp_service.unsubscribe_from_all_lists

    User.all.each do |user|
      if user.current_user_subscription
        if user.current_user_subscription.active_trial?
          mailchimp_service.subscribe_to_trial(user)
        elsif user.current_user_subscription.active_full?
          mailchimp_service.subscribe_to_paid(user)
        end
      elsif user.primary_shared_of_paid?
        mailchimp_service.subscribe_to_shared(user)
      end
    end
  end
end
