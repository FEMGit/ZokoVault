class ContactService
  attr_reader :user
  
  def self.filter_contacts(contact_ids)
    cids = contact_ids.flatten.uniq
    Contact.where(id: cids).pluck(:id)
  end

  def initialize(user:)
    @user = user
  end

  def contacts_shareable
    contacts.reject { |c| contact_all_emails_rejected.include?(c.emailaddress) }
  end
  
  def contact_corporate_emails_rejected
    user.corporate_users.try(:map, &:email).try(:map, &:downcase) || []
  end
  
  def contact_all_emails_rejected
    contact_corporate_emails_rejected << user.email.downcase
  end
  
  def contacts
    @contacts ||= user.contacts.reject { |c| contact_corporate_emails_rejected.include?(c.emailaddress) }
  end
end
