class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  
  add_breadcrumb "Guided Tutorial - Important Documents", :tutorial_important_documents_path, only: [:important_documents]
  include BreadcrumbsCacheModule
  
  def page_name
    case action_name
      when 'primary_contacts'
        "Guided Tutorial - Primary Contacts"
      when 'trusted_advisors'
        "Guided Tutorial - Trusted Advisors"
      when 'important_documents'
        "Guided Tutorial - Important Documents"
      when 'category_setup'
        "Guided Tutorial - Category Setup"
    end
  end
  
  def primary_contacts
    @primary_contacts = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Family & Beneficiaries'], contact_type: 'Family & Beneficiaries')
  end
  
  def trusted_advisors
    @trusted_advisors = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Advisor'], contact_type: 'Advisor')
  end
  
  def important_documents
    @documents = Document.for_user(current_user)
    session[:ret_url] = tutorial_important_documents_path
  end
  
  def category_setup; end
  
  private
  
  def set_new_contact
    @contact = Contact.new(user: current_user)
  end
end
