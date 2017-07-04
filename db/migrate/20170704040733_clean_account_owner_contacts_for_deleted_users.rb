class CleanAccountOwnerContactsForDeletedUsers < ActiveRecord::Migration
  def change
    corporate_users_contact_emails = Contact.joins("INNER JOIN users on contacts.user_id = users.id and
                                                    contacts.relationship='Account Owner' and
                                                    contacts.emailaddress != users.email").map(&:emailaddress)
    active_corporate_user_emails = CorporateAdminAccountUser.all.map(&:user_account).map(&:email)
    user_emails_to_remove = corporate_users_contact_emails - active_corporate_user_emails
    Contact.where(emailaddress: user_emails_to_remove, relationship: 'Account Owner').destroy_all
  end
end
