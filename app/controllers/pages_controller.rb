class PagesController < HighVoltage::PagesController
  include UserTrafficModule
  include BreadcrumbsCacheModule
  include BackPathHelper
  include TutorialsHelper
  before_action :save_return_to_path, only: [:show]
  before_action :set_cache_headers
  before_action :set_tutorial, :set_contacts, :set_shares_information, only: [:show]
  layout 'without_sidebar_layout'
  
  before_action :redirect_to_last_tutorial, :save_tutorial_progress, only: [:show]
  
  def page_name
    return unless current_user.present? &&
                  params[:tutorial_id].present?
    case action_name
      when 'show'
        @tutorial_name = params[:tutorial_id]
        @tutorial = Tutorial.where('name ILIKE ?', tutorial_name(@tutorial_name)).first
        "Guided Tutorial - #{@tutorial.try(:name)}" 
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

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

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
      @insurance_brokers = Contact.for_user(current_user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor')
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
    
    # Check that 'Spouse' was added
    if @page_number.to_i > 1 && !@primary_contacts.any? { |pc| pc.relationship.eql? 'Spouse / Domestic Partner' }
      spouse_not_added_handle
    elsif @page_number.to_i == 1
      if session[:tutorial_paths][session[:tutorial_index] + 1][:tuto_id].to_s != @tutorial.id.to_s
        restore_family_tutorial_session
      end
    end
  end
  
  def redirect_if_incorrect_url
    current_tutorial_path = Rails.application.routes.recognize_path(request.fullpath)
    if current_tutorial_path[:tutorial_id] != @tutorial_name
      redirect_to tutorial_page_path(@tutorial_name, @page_number)
    end
  end
  
  def spouse_not_added_handle
    tuto_index = session[:tutorial_index]
    return unless tuto_index
      session[:tutorial_index] += @tutorial.number_of_pages - 1
      (1...@tutorial.number_of_pages).each do 
        session[:tutorial_paths].delete_at(tuto_index)
        session[:tutorial_index] -= 1
      end
      reset_tutorial_parameters
  end
  
  def restore_family_tutorial_session
    current_tutorial_params = {:tuto_id=>@tutorial.id.to_s, :current_page=>@page_number.to_i, :tuto_name=> params[:tutorial_id]}
    tutorial_path_position = session[:tutorial_paths].index(current_tutorial_params)
    subtutorial_paths = []
    (2..@tutorial.number_of_pages).each do |page_number|
      subtutorial_paths << { tuto_id: @tutorial.id, current_page: page_number, tuto_name: params[:tutorial_id] }
    end
    session[:tutorial_paths] = session[:tutorial_paths][0..tutorial_path_position] +
                               subtutorial_paths + 
                               session[:tutorial_paths][tutorial_path_position + 1..-1]
    reset_tutorial_parameters
  end
  
  def reset_tutorial_parameters
    params[:tutorial_id] = session[:tutorial_paths][session[:tutorial_index]][:tuto_name]
    params[:page_id] = session[:tutorial_paths][session[:tutorial_index]][:current_page]
    set_tutorial
  end
  
  def set_taxes_tutorial_contacts
    @digital_taxes = Document.for_user(current_user).where(category: Rails.application.config.x.TaxCategory)
    
    @tax_accountants = Contact.for_user(current_user).where(relationship: 'Accountant', contact_type: 'Advisor')
    set_documents_information(Rails.application.config.x.TaxCategory)
    set_contact_and_category_share(@tax_accountants, Rails.application.config.x.TaxCategory)
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
  
  def set_documents_information(category_name)
    @category_dropdown_options = Array.wrap(category_name)
    service = DocumentService.new(:category => category_name)
    @card_names = service.get_card_names(current_user, current_user)
    @cards = service.get_card_values(current_user, current_user)
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
