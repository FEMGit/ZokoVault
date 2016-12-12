class FinancialInformationController < AuthenticatedController
  before_action :set_contacts, only: [:add_account, :add_property, :add_investment]
  
  def add_account; end
  
  def add_property; end
  
  def add_investment; end
  
  private
  
  def set_contacts
    @contacts = Contact.for_user(current_user)
  end
end
