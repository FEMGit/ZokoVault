class AddCorporateUsersToMailchimpList < ActiveRecord::Migration
  def change
    mailchimp_service = MailchimpService.new
    
    User.all.select { |u| u.corporate_manager? }.each do |corporate_manager|
      mailchimp_service.subscribe_to_corporate(corporate_manager)
    end
  end
end
