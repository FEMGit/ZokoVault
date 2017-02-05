class ContactService
  attr_reader :contacts

  def initialize(params)
    @user = params[:user]
    set_contacts
  end

  def contacts_shareable
    @contacts.reject { |c| c.emailaddress == @user.email }
  end
  
  def self.filter_contacts(contact_ids)
    Contact.pluck(:id).select { |x| contact_ids.include? x }
  end

  private

  def set_contacts
    @contacts = Contact.for_user(@user)
  end
end
