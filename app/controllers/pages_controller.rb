class PagesController < HighVoltage::PagesController
  include BreadcrumbsCacheModule
  include TutorialsHelper
  before_action :set_cache_headers
  before_action :set_tutorial, :set_contacts, only: [:show]
  layout 'without_sidebar_layout'

  def show
    redirect_to new_tutorial_path and return if session[:tutorial_paths].blank?
    @show_footer = false
    tuto_index = session[:tutorial_index] + 1
    
    if @tutorial_name.eql? 'confirmation_page'
      redirect_to tutorials_confirmation_path and return
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
      clean_subtutorials
    end
  end

  def set_contacts
    if @tutorial_name.include? 'i-have-a-family'
      set_primary_shared_tutorial_contacts
    elsif @tutorial_name.include? 'i-have-insurance'
      @insurance_brokers = Contact.for_user(current_user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor')
    elsif @tutorial_name.include? 'i-have-tax-documents'
      set_taxes_tutorial_contacts
    elsif @tutorial_name.include? 'i-have-a-trust'
      set_trusts_tutorial_contacts
    elsif @tutorial_name.include? 'i-have-a-will'
      set_wills_tutorial_contacts
    elsif @tutorial_name.include? 'i-have-financial-information'
      set_financial_information_tutorial_contacts
    end
    @contact = Contact.new(user: current_user)
  end
  
  def set_primary_shared_tutorial_contacts
    @user_profile = UserProfile.for_user(current_user)
    @primary_contacts = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Family & Beneficiaries'], contact_type: 'Family & Beneficiaries')
    
    @primary_shared_contacts = @user_profile.primary_shared_with
    @contacts_with_access = (@primary_contacts + @primary_shared_contacts).uniq
    
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
  end
  
  def set_taxes_tutorial_contacts
    @digital_taxes = Document.for_user(current_user).where(category: Rails.application.config.x.TaxCategory)
    
    @tax_accountants = Contact.for_user(current_user).where(relationship: 'Accountant', contact_type: 'Advisor')
    set_contact_and_category_share(@tax_accountants, Rails.application.config.x.TaxCategory)
  end
  
  def set_trusts_tutorial_contacts
    @trust_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    set_contact_and_category_share(@trust_planning_attorneys, Rails.application.config.x.TrustsEntitiesCategory)
  end
  
  def set_wills_tutorial_contacts
    @digital_wills = Document.for_user(current_user).where(category: Rails.application.config.x.WillsPoaCategory)
    
    @estate_planning_attorneys = Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor')
    set_contact_and_category_share(@estate_planning_attorneys, Rails.application.config.x.WillsPoaCategory)
  end
  
  def set_financial_information_tutorial_contacts
    @financial_advisors = Contact.for_user(current_user).where(relationship: 'Financial Advisor / Broker', contact_type: 'Advisor')
    set_contact_and_category_share(@financial_advisors, Rails.application.config.x.FinancialInformationCategory)
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
