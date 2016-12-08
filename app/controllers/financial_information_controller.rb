class FinancialInformationController < AuthenticatedController
  before_action :set_contacts, only: [:add_account]
  
  def add_account; end
  
  private
  
  def set_contacts
    @contacts = Contact.for_user(current_user)
  end
end
