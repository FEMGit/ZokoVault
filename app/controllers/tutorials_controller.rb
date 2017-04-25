class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  before_action :set_order_params, only: [:new, :insurance]
  layout 'blank_layout', only: [:new, :create, :show, :insurance]

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
    set_tutorials(Tutorial.first(4))
  end
  
  def insurance
    set_tutorials(Tutorial.where(category: Category.fetch('insurance')))
  end
  
  def set_tutorials(tutorial_collection)
    @tutorial_array = tutorial_collection
    @tutorial = Tutorial.new(name: session[:order_params])
    @tutorial.current_step = session[:order_step]
  end

  def create
    session[:order_params] = params["tutorial"] if params["tutorial"]
    @tutorial              = Tutorial.new(name: session[:order_params].first || 'Nothing')
    @tutorial.current_step = session[:order_step]
    @current_tutorial = nil
    @current_tutorial      = Tutorial.find(session[:order_params].shift) if session[:order_params].present?
    @tutorial_array        = Tutorial.where(id: session[:order_params])

    if @tutorial.valid?
      if @tutorial.last_step?
        session[:order_step] = session[:order_params] = nil
        # TODO: see what url should we redirect
        redirect_to tutorial_path(Tutorial.last) and return
      elsif @tutorial.current_step == 'initial' || @current_tutorial.blank?
        @tutorial.next_step
      end
      session[:order_step] = @tutorial.current_step
    end
    if @tutorial.new_record?
      render "new"
    else
      session[:order_step] = session[:order_params] = nil
      flash[:notice]       = "Tutorial saved!"
      redirect_to @tutorial
    end
  end

  def show
    @tutorial = Tutorial.find(params[:id])
  end

  private
  
  def set_order_params
    session[:order_params] ||= {}
  end

  def set_new_contact
    @contact = Contact.new(user: current_user)
  end
end
