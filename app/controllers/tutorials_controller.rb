class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  include TutorialsHelper
  include FinancialInformationHelper
  include BreadcrumbsCacheModule
  before_action :set_cache_headers
  before_action :save_return_to_path, :save_tutorial_progress, only: [:new, :confirmation, :show]
  before_action :set_tutorial, :set_contacts, :set_balance_sheet, :set_shares_information, only: [:show]
  before_action :redirect_to_last_tutorial, only: [:new, :show]
  
  skip_before_filter :complete_setup!, except: :show
  layout 'without_sidebar_layout'

  after_action only: [:create, :update, :destroy, :new] do
    save_tutorial_progress
  end

  def page_name
    case action_name
      when 'lets_get_started'
        "Guided Tutorial - Lets Get Started"
      when 'vault_co_owners'
        "Guided Tutorial - Vault Co-Owner"
      when 'confirmation'
        "Guided Tutorial - Confirmation"
      when 'new'
        "Guided Tutorial - Start"
      when 'show'
        @tutorial_name = params[:tutorial_id]
        @tutorial = Tutorial.where('name ILIKE ?', tutorial_name(@tutorial_name)).first
        "Guided Tutorial - #{@tutorial.try(:name)}" 
    end
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
      if params[:next_tutorial_path].present?
        recognized_path = Rails.application.routes.recognize_path(params[:next_tutorial_path]) rescue nil
        redirect_to root_path if recognized_path.nil? and return
        redirect_to recognized_path
      elsif params[:next_tutorial] == 'confirmation_page'
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
      if params[:next_tutorial_path].present? &&
         (Rails.application.routes.recognize_path(params[:next_tutorial_path]) rescue nil).present?
        redirect_to params[:next_tutorial_path] and return
      end
      redirect_to tutorial_page_path(tuto_name, next_page) and return
    end
  end

  def show
    redirect_to new_tutorial_path and return if session[:tutorial_paths].blank?
    @show_footer = false
    tuto_index = session[:tutorial_index] + 1
    
    if @tutorial_name.eql? 'confirmation_page'
      redirect_to tutorials_confirmation_path and return
    elsif @tutorial_name.eql? 'vault_co_owners'
      redirect_to tutorials_vault_co_owners_path and return
    end

    if session[:tutorial_paths][tuto_index]
      @next_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]
    else
      redirect_to new_tutorial_path and return
    end

    @next_tutorial = Tutorial.where('name ILIKE ?', tutorial_name(@next_tutorial_name)).first
    @next_page = session[:tutorial_paths][tuto_index][:current_page]
    @page_name     = "page_#{@page_number}"

    session[:tutorial_index] = session[:tutorial_index] + 1
  end

  def destroy
    tuto_index = session[:tutorial_index] - 2
    tuto_index = tuto_index < 0 ? 0 : tuto_index
    # Destroy element if it was created
    return_path = 
      if session[:category_tutorial_in_progress].eql?(true)
        params[:return_path]
      else
        new_tutorial_path
      end
    redirect_to return_path and return if session[:tutorial_paths].blank?
    insurance_card = session[:tutorial_paths][tuto_index][:object]
    insurance_card.destroy if insurance_card
    @prev_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]

    if @prev_tutorial_name == 'tutorial_new'
      session[:tutorial_index] = 0
      redirect_to return_path and return
    elsif @prev_tutorial_name == 'balance-sheet' && !financial_information_any?
      tuto_index -= 1
      session[:tutorial_index] -= 1
      redirect_to return_path and return if session[:tutorial_index] <= 0
      @prev_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]
    end

    @prev_tutorial = Tutorial.find_by(name: @prev_tutorial_name.titleize)
    @prev_page = session[:tutorial_paths][tuto_index][:current_page]
    session[:tutorial_index] = session[:tutorial_index] - 2
    redirect_to return_path and return if session[:category_tutorial_in_progress].eql?(true)
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
    add_digital_wills_subtutorial
    render :json => {}, :status => 200
  end

  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def add_digital_wills_subtutorial
    if subtutorial_id_params[:subtutorial_ids].present?
      tuto_index = session[:tutorial_index]
      tutorial_id = session[:tutorial_paths][tuto_index - 1][:tuto_id].to_i
      tutorial_path_update({"2" => params[:subtutorial_ids].first }, tutorial_id)
    end
  end
  
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
    result << { tuto_id: -1, current_page: 1, tuto_name: 'balance-sheet' } # tutorial / balance-sheet page
    result << { tuto_id: -1, current_page: 1, tuto_name: 'shares' } # tutorial / shares main page
    result << { tuto_id: -1, current_page: 1, tuto_name: 'confirmation_page' } # tutorial / confirmation page
  end
  
  def tutorial_path_update(subtutorial_pages, tuto_index)
    tutorial = Tutorial.find(tuto_index)
    
    subtutorials_path = []
    subtutorial_pages.try(:each) do |number, id|
      subtutorial = 
        if id.include? 'tutorial_'
          Tutorial.find_by(:id => id.scan(/\d+/).first)
        else
          Subtutorial.find_by(:id => id)
        end
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
  
  # Prepare resources section
  
  def set_tutorial
    # Params = {"tutorial_id"=>"insurance", "page_id"=>"1"}
    @page_number   = params[:page_id]
    @tutorial_name = params[:tutorial_id]
    @tutorial      = Tutorial.where('name ILIKE ?', tutorial_name(@tutorial_name)).first
    if @tutorial_name != 'confirmation_page'
      @subtutorials = @tutorial.try(:subtutorials).try(:sort_by, &:id)
                                                  .try(:sort_by, &:position)
      clean_subtutorials
    end
  end

  def set_contacts
    return unless current_user
    if @tutorial_name.include? 'my-family'
      set_primary_shared_tutorial_contacts
    elsif @tutorial_name.include? 'my-insurance'
      set_insurance_tutorial_contacts
    elsif @tutorial_name.include? 'my-taxes'
      set_taxes_tutorial_contacts
    elsif @tutorial_name.include? 'my-trust(s)'
      set_trusts_tutorial_contacts
    elsif @tutorial_name.include? 'my-will(s)'
      set_wills_tutorial_contacts
    elsif @tutorial_name.include? 'my-financial-information'
      set_financial_information_tutorial_contacts
    end
    @contact = Contact.new(user: current_user)
    redirect_if_incorrect_url
  end
  
  def set_balance_sheet
    set_balance_sheet_information(@tutorial_name)
  end
  
  def set_shares_information
    if @tutorial_name.eql? 'shares'
      case @page_number.to_i
        when 1
          update_shares_tutorial_path
        when 2
          set_taxes_tutorial_contacts
        when 3
          set_financial_information_tutorial_contacts
        when 4
          set_wills_tutorial_contacts
        when 5
          set_trusts_tutorial_contacts
      end
    end
  end
  
  def update_shares_tutorial_path
    @tax_accountants = Contact.for_user(current_user).where(relationship: 'Accountant', contact_type: 'Advisor')
    @financial_advisors = Contact.for_user(current_user).where(relationship: 'Financial Advisor / Broker', contact_type: 'Advisor')
    @estate_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    @trust_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    if @tax_accountants.blank? && @financial_advisors.blank? && 
        @estate_planning_attorneys.blank? && @trust_planning_attorneys.blank?
      redirect_to tutorials_confirmation_path and return;
    else
      add_shares_tutorials
    end
  end
  
  def shares_tutorial_clear
    shares_tutorial_params = { name: 'shares', tuto_id: -1}
    shares_tutorial = Tutorial.where("name ilike ?", shares_tutorial_params[:name].downcase).first
    (2..5).each do |tutorial_index|
      session[:tutorial_paths].delete(tutorial_path_hash(shares_tutorial_params[:tuto_id], tutorial_index, shares_tutorial))
    end
  end
  
  def add_shares_tutorials
    shares_tutorial_clear
    shares_tutorial_params = { name: 'shares', tuto_id: -1}
    shares_tutorial = Tutorial.where("name ilike ?", shares_tutorial_params[:name].downcase).first
    subtutorials_path = []
    subtutorials_path << tutorial_path_hash(shares_tutorial_params[:tuto_id], 2, shares_tutorial) if @tax_accountants.present?
    subtutorials_path << tutorial_path_hash(shares_tutorial_params[:tuto_id], 3, shares_tutorial) if @financial_advisors.present?
    subtutorials_path << tutorial_path_hash(shares_tutorial_params[:tuto_id], 4, shares_tutorial) if @estate_planning_attorneys.present?
    subtutorials_path << tutorial_path_hash(shares_tutorial_params[:tuto_id], 5, shares_tutorial) if @trust_planning_attorneys.present?

    tutorial_path_position = session[:tutorial_paths].index({:tuto_id=>shares_tutorial_params[:tuto_id], :current_page=>1, :tuto_name=> shares_tutorial_params[:name]})
    session[:tutorial_paths] = session[:tutorial_paths][0..tutorial_path_position] +
                               subtutorials_path +
                               session[:tutorial_paths][tutorial_path_position + 1..-1]
  end
  
  def set_primary_shared_tutorial_contacts
    @user_profile = UserProfile.for_user(current_user)
    @primary_contacts = Contact.for_user(current_user).where(contact_type: 'Family & Beneficiaries')
    
    @primary_shared_contacts = @user_profile.primary_shared_with
    @contacts_with_access = (@primary_contacts.select{ |pc| pc.relationship.eql? 'Spouse / Domestic Partner' } + @primary_shared_contacts).uniq
    
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
    
    @family_records = Document.for_user(current_user).where(category: [Rails.application.config.x.ContactCategory, Rails.application.config.x.ProfileCategory])
    set_documents_information(Rails.application.config.x.ContactCategory, [Rails.application.config.x.ContactCategory,
                                                                           Rails.application.config.x.ProfileCategory])
  end
  
  def redirect_if_incorrect_url
    current_tutorial_path = Rails.application.routes.recognize_path(request.fullpath)
    if current_tutorial_path[:tutorial_id] != @tutorial_name
      redirect_to tutorial_page_path(@tutorial_name, @page_number)
    end
  end
  
  def contact_not_added_handle(from, number_of_pages)
    tuto_index = session[:tutorial_index]
    return unless tuto_index
    session[:tutorial_index] += number_of_pages - 1
    (from..number_of_pages).each do
      session[:tutorial_paths].delete_at(tuto_index)
      session[:tutorial_index] -= 1
    end
    reset_tutorial_parameters
  end
  
  def restore_tutorial_session(from_page_number, number_of_pages)
    current_tutorial_params = {:tuto_id => @tutorial.id, :current_page => @page_number.to_i, :tuto_name => params[:tutorial_id]}
    tutorial_path_position = session[:tutorial_paths].index(current_tutorial_params)
    subtutorial_paths = []
    (from_page_number..number_of_pages).each do |page_number|
      tutorial_to_add = { tuto_id: @tutorial.id, current_page: page_number, tuto_name: params[:tutorial_id] }
      next if session[:tutorial_paths].index(tutorial_to_add).present?
      subtutorial_paths << { tuto_id: @tutorial.id, current_page: page_number, tuto_name: params[:tutorial_id] }
    end
    session[:tutorial_paths] = session[:tutorial_paths][0..tutorial_path_position] +
                               subtutorial_paths + 
                               session[:tutorial_paths][tutorial_path_position + 1..-1]
    reset_tutorial_parameters
  end
  
  def redirect_if_incorrect_url
    current_tutorial_path = Rails.application.routes.recognize_path(request.fullpath)
    if current_tutorial_path[:tutorial_id] != @tutorial_name
      redirect_to tutorial_page_path(@tutorial_name, @page_number)
    end
  end
  
  def reset_tutorial_parameters
    params[:tutorial_id] = session[:tutorial_paths][session[:tutorial_index]][:tuto_name]
    params[:page_id] = session[:tutorial_paths][session[:tutorial_index]][:current_page]
    set_tutorial
  end
  
  def set_insurance_tutorial_contacts
    @insurance_brokers = Contact.for_user(current_user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor')
    @insurance_policies = Document.for_user(current_user).where(category: Rails.application.config.x.InsuranceCategory)
    set_documents_information(Rails.application.config.x.InsuranceCategory)
  end
  
  def set_taxes_tutorial_contacts
    @digital_taxes = Document.for_user(current_user).where(category: Rails.application.config.x.TaxCategory)
    
    @tax_accountants = Contact.for_user(current_user).where(relationship: 'Accountant', contact_type: 'Advisor')
    set_documents_information(Rails.application.config.x.TaxCategory)
    set_contact_and_category_share(@tax_accountants, Rails.application.config.x.TaxCategory)
    
    # Check that 'Attorney' was added
    if @page_number.to_i == 2 && !@tax_accountants.any? { |pc| (pc.relationship.eql? 'Accountant') && (pc.contact_type.eql? 'Advisor') }
      contact_not_added_handle(2, 2)
    elsif @page_number.to_i == 1
      restore_tutorial_session(2, 2)
    end
  end
  
  def set_trusts_tutorial_contacts
    @trust_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    set_contact_and_category_share(@trust_planning_attorneys, Rails.application.config.x.TrustsEntitiesCategory)
  end
  
  def set_wills_tutorial_contacts
    @digital_wills = Document.for_user(current_user).where(category: Rails.application.config.x.WillsPoaCategory)
    
    @estate_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    set_documents_information(Rails.application.config.x.WillsPoaCategory)
    set_contact_and_category_share(@estate_planning_attorneys, Rails.application.config.x.WillsPoaCategory)
  end
  
  def set_financial_information_tutorial_contacts
    @financial_advisors = Contact.for_user(current_user).where(relationship: 'Financial Advisor / Broker', contact_type: 'Advisor')
    set_contact_and_category_share(@financial_advisors, Rails.application.config.x.FinancialInformationCategory)
  end
  
  def set_documents_information(category_name, dropdown_option_names = nil)
    @category = Category.fetch(category_name.downcase)
    @category_dropdown_options, @card_names, @cards = TutorialService.set_documents_information(category_name, current_user, dropdown_option_names)
  end
  
  def set_contact_and_category_share(contact_collection, category_name)
    @contacts = Contact.for_user(current_user).reject { |c| c.emailaddress == current_user.email } 
    @category = Category.fetch(category_name.downcase)

    @contacts_with_access = (current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) +
                             contact_collection).uniq
    @shareable_category = ShareableCategory.new(current_user,
                                                @category.id, 
                                                @contacts_with_access.map(&:id))
  end
  
  def clean_subtutorials
    if @tutorial && @tutorial.has_subtutorials?
      tuto_index = session[:tutorial_index]
      return if tuto_index.blank? || session[:tutorial_paths].blank?
      tuto_id = session[:tutorial_paths][tuto_index][:tuto_id]
      if session[:tutorial_paths][tuto_index][:current_page].eql? 'subtutorials_choice'
        session[:tutorial_paths].delete_if { |x| x[:tuto_id].to_s == tuto_id.to_s && x[:current_page] != 'subtutorials_choice' }
      end
    end
  end
end
