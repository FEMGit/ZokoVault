class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  layout 'without_sidebar_layout'

  before_action :set_blank_layout_header_info, only: [:primary_contacts, :trusted_advisors,
                                                      :important_documents, :video, :new_document]

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
      when 'Video'
        "Guided Tutorial - Video"
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

  def new_document
  end

  def video; end

  def new
    session[:tutorials_list] ||= {}
    @tutorial_array = Tutorial.all
    @tutorial = Tutorial.new(name: session[:tutorials_list])
    @tutorial.current_step = session[:order_step]
  end

  def create
    if params["tutorial"].present?
      session[:tutorials_list] = params["tutorial"]
    else
      flash[:error] = 'Select at least one Tutorial checkbox'
      session[:tutorials_list] ||= {}
      @tutorial_array = Tutorial.first(3)
      @tutorial = Tutorial.new(name: session[:tutorials_list])
      @tutorial.current_step = session[:order_step]

      render :new
      return
    end
    session[:tutorial_paths] = tutorial_path_generator session[:tutorials_list]
    session[:tutorial_index] = 1
    tuto_index = session[:tutorial_index]
    tuto_id = session[:tutorial_paths][tuto_index][:tuto_id]
    @current_tutorial = Tutorial.find tuto_id
    current_tutorial_name = @current_tutorial.slug.parameterize

    redirect_to tutorial_page_path(current_tutorial_name, '1')
  end

  def show
    @tutorial = Tutorial.find(params[:id])
  end

  def destroy
    tuto_index = session[:tutorial_index] - 2
    # Destroy element if it was created
    insurance_card = session[:tutorial_paths][tuto_index][:object]
    insurance_card.destroy if insurance_card
    @prev_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]

    if @prev_tutorial_name == 'tutorial_new'
      redirect_to new_tutorial_path and return
    end

    @prev_tutorial = Tutorial.find_by(slug: @prev_tutorial_name.titleize)
    @prev_page = session[:tutorial_paths][tuto_index][:current_page]
    session[:tutorial_index] = session[:tutorial_index] - 2

    redirect_to tutorial_page_path(@prev_tutorial_name, @prev_page)
  end

  private

  def set_blank_layout_header_info
    @header_information = true
  end

  def set_new_contact
    @contact = Contact.new(user: current_user)
  end

  def tutorial_path_generator(list)
    result = [{ tuto_id: 0, current_page: 0, tuto_name: 'tutorial_new' }] # tutorial / new
    list.each do |tuto|
      tutorial = Tutorial.find(tuto)
      tutorial.number_of_pages.times do |p|
        result << {
          tuto_id: tuto,
          current_page: p + 1,
          tuto_name: tutorial.slug.split(" ").join("-").downcase }
      end
    end
    result << { tuto_id: -1, current_page: 1, tuto_name: 'confirmation_page' } # tutorial / confirmation page
  end
end
