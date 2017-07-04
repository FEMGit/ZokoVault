class ContactService
  attr_reader :contacts

  def initialize(params)
    @user = params[:user]
    set_contacts
  end

  def contacts_shareable
    @contacts.reject { |c| contact_all_emails_rejected.include? c.emailaddress }
  end
  
  def self.filter_contacts(contact_ids)
    Contact.pluck(:id).select { |x| contact_ids.include? x }
  end
  
  def contact_corporate_emails_rejected
    @user.corporate_users.try(:map, &:email).try(:map, &:downcase)
  end
  
  def contact_all_emails_rejected
    @user.corporate_users.try(:map, &:email).try(:map, &:downcase) << @user.email.downcase
  end
  
  private

  def set_contacts
    @contacts = Contact.for_user(@user).reject { |c| contact_corporate_emails_rejected.include? c.emailaddress }
  end
end
