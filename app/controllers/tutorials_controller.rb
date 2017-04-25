class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  layout 'blank_layout', only: [:new, :create, :show]

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

  def new
    session[:tutorials_list] ||= {}
    @tutorial_array = Tutorial.first(3)
    @tutorial = Tutorial.new(name: session[:tutorials_list])
    @tutorial.current_step = session[:order_step]
  end

  def create
    session[:tutorials_list] = params["tutorial"] if params["tutorial"]
    session[:tutorial_index] = 0
    session[:failed_saved_tutorial] = false
    if session[:tutorials_list].present?
      @current_tutorial = Tutorial.find(session[:tutorials_list][session[:tutorial_index]])
    end
    current_tutorial_name = @current_tutorial.name.parameterize
    session[:tutorial_index] = 1

    redirect_to tutorial_page_path(current_tutorial_name, '1')
  end

  def show
    @tutorial = Tutorial.find(params[:id])
  end

  def destroy
    previous_url = session[:previous_tuto].last[:my_previous_url]

    if session[:previous_tuto].last[:class_object]
      eval(session[:previous_tuto].last[:class_object]).find(session[:previous_tuto].last[:object][:id]).destroy
    end

    if session[:previous_tuto].last[:reduce_tutorial_index]
      if previous_url.include? 'home'
        session[:tutorial_index] = 2
      elsif previous_url.include? 'insurance'
        session[:tutorial_index] = 1
      else
        session[:tutorial_index] = 3
      end
    end

    session[:prev_tutorial_added] = true

    session[:previous_tuto].pop
    redirect_to previous_url
  end

  private

  def set_new_contact
    @contact = Contact.new(user: current_user)
  end
end
