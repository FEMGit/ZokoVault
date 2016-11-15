class ContactService
  def initialize(params)
    @user = params[:user]
    set_contacts
  end

  def contacts_shareable
    @contacts.reject { |c| c.emailaddress == @user.email }
  end
  
  def contacts
    @contacts.collect { |c| [c.id, c.name] }.prepend([])
  end

  private

  def set_contacts
    @contacts = Contact.for_user(@user)
  end
end
