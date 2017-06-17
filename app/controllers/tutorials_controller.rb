class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  include TutorialsHelper
  before_action :save_return_to_path, only: [:new, :confirmation, :show]
  skip_before_filter :complete_setup!, except: :show
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  layout 'without_sidebar_layout'

  before_action :set_blank_layout_header_info, only: [:primary_contacts, :trusted_advisors,
                                                      :important_documents, :video, :new_document]
  
  before_action :redirect_to_last_tutorial, only: [:new]
  before_action :save_tutorial_progress, only: [:confirmation]
  after_action only: [:create, :update, :destroy, :new] do
    save_tutorial_progress
  end

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
  
  def lets_get_started
    tutorial_progress_save('lets_get_started')
  end
  
  def vault_co_owners
    @user_profile = UserProfile.for_user(current_user)
    @contact = Contact.new(user: current_user)
    @primary_contacts = Contact.for_user(current_user).where(contact_type: 'Family & Beneficiaries')
    @tutorial_name = "account_co_owner"
    @page_number = 0
    tutorial_progress_save('vault_co_owners')
  end
  
  def confirmation
    session[:tutorial_index] = session[:tutorial_index].present? ? (session[:tutorial_index] + 1) : 1
    params[:tutorial_id] = 'confirmation_page'
    @tutorial_name = 'confirmation_page'
  end
  
  def tutorials_end
    clean_tutorial_progress
    redirect_to root_path
  end

  def video; end

  def new
    tutorials_initialization
    redirect_to current_tutorial_path if current_tutorial_path.present?
  end

  def create
    if params["tutorial"].present?
      session[:tutorials_list] = params["tutorial"]
    else
      session[:tutorial_index] += 1
      redirect_to tutorial_page_path('shares', 1) and return
    end
    session[:tutorial_paths] = tutorial_path_generator session[:tutorials_list]
    session[:tutorial_index] = 1
    tuto_index = session[:tutorial_index]
    tuto_id = session[:tutorial_paths][tuto_index][:tuto_id]
    tuto_page = session[:tutorial_paths][tuto_index][:current_page]
    @current_tutorial = Tutorial.find tuto_id
    current_tutorial_name = @current_tutorial.name.parameterize
    redirect_to tutorial_page_path(current_tutorial_name, tuto_page)
  end
  
  def update
    if params[:tutorial].blank?
      if params[:next_tutorial] == 'confirmation_page'
        redirect_to tutorials_confirmation_path and return
      else
        tuto_index = session[:tutorial_index]
        tuto_name = session[:tutorial_paths][tuto_index][:tuto_name]
        next_page = session[:tutorial_paths][tuto_index][:current_page]
        redirect_to tutorial_page_path(tuto_name, next_page) and return
      end
    else
      subtutorial_pages = params[:tutorial][:pages]
      
      tuto_index = session[:tutorial_index]
      tutorial_id = session[:tutorial_paths][tuto_index - 1][:tuto_id].to_i
      tutorial_path_update(subtutorial_pages, tutorial_id)
      tuto_name = session[:tutorial_paths][tuto_index][:tuto_name]
      next_page = session[:tutorial_paths][tuto_index][:current_page]
      
      redirect_to tutorial_page_path(tuto_name, next_page) and return
    end
  end

  def show
    @tutorial = Tutorial.find(params[:id])
  end

  def destroy
    tuto_index = session[:tutorial_index] - 2
    tuto_index = tuto_index < 0 ? 0 : tuto_index
    # Destroy element if it was created
    redirect_to new_tutorial_path and return if session[:tutorial_paths].blank?
    insurance_card = session[:tutorial_paths][tuto_index][:object]
    insurance_card.destroy if insurance_card
    @prev_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]

    if @prev_tutorial_name == 'tutorial_new'
      session[:tutorial_index] = 0
      redirect_to new_tutorial_path and return
    end

    @prev_tutorial = Tutorial.find_by(name: @prev_tutorial_name.titleize)
    @prev_page = session[:tutorial_paths][tuto_index][:current_page]
    session[:tutorial_index] = session[:tutorial_index] - 2
    redirect_to tutorial_page_path(@prev_tutorial_name, @prev_page)
  end
  
  def create_wills
    subtutorial_id_params[:subtutorial_ids].each do |subtutorial_id|
      tutorial_name = Subtutorial.find_by(:id => subtutorial_id).try(:name)
      return unless tutorial_name.present?
      begin
        if tutorial_name.eql? 'My will.'
          Will.create!(title: current_user.name + ' Will', user: current_user)
        elsif tutorial_name.eql? "My spouse's will."
          spouse_contacts = Contact.for_user(current_user).where(relationship: 'Spouse / Domestic Partner')
          spouse_contacts.map { |sc| Will.create!(title: sc.name + ' Will', user: current_user) }
        end
      rescue
        render :json => { :errors => 'Error saving a record, please try again.' }, :status => 500
      end
    end
    render :json => {}, :status => 200
  end

  private
  
  def tutorial_progress_save(tuto_name)
    tutorial_selection = TutorialSelection.find_or_create_by(user_id: current_user.try(:id))
    session[:tutorial_paths] = {}
    tutorial_selection.tutorial_paths = [{ tuto_id: 0, current_page: 0, tuto_name: tuto_name }]
    tutorial_selection.last_tutorial_index = 0
    tutorial_selection.save!
  end
  
  def tutorials_initialization
    session[:tutorials_list] ||= {}
    session[:tutorial_paths] = {}
    @tutorial_array = Tutorial.all.sort_by(&:position)
    @tutorial = Tutorial.new(name: session[:tutorials_list])
    @tutorial.current_step = session[:order_step]
    session[:tutorial_paths] = tutorial_path_generator []
    session[:tutorial_index] = 0
  end

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
      if tutorial.has_subtutorials?
        result << tutorial_path_hash(tuto, 'subtutorials_choice', tutorial)
      else
        tutorial.number_of_pages.times do |p|
          result << tutorial_path_hash(tuto, p + 1, tutorial)
        end
      end
    end
    result << { tuto_id: -1, current_page: 1, tuto_name: 'shares' } # tutorial / shares main page
    result << { tuto_id: -1, current_page: 1, tuto_name: 'confirmation_page' } # tutorial / confirmation page
  end
  
  def tutorial_path_update(subtutorial_pages, tuto_index)
    tutorial = Tutorial.find(tuto_index)
    
    subtutorials_path = []
    subtutorial_pages.try(:each) do |number, id|
      subtutorial = Subtutorial.find_by(:id => id)
      next unless subtutorial.present?
      (number.to_i ... number.to_i + subtutorial.number_of_pages).each do |page_numer|
        subtutorials_path << page_numer
      end
    end
    
    tuto_name = tutorial_id(tutorial.name)
    tutorial_path_position = session[:tutorial_paths].index({:tuto_id=>tuto_index.to_s, :current_page=>"subtutorials_choice", :tuto_name=> tuto_name})
    
    session[:tutorial_paths] = session[:tutorial_paths][0..tutorial_path_position] +
                               subtutorials_path.collect { |s| tutorial_path_hash(tuto_index, s, tutorial) } +
                               session[:tutorial_paths][tutorial_path_position + 1..-1]
  end
  
  def subtutorial_id_params
    params.permit(subtutorial_ids: [])
  end
end
