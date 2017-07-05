class SharedViewController < AuthenticatedController
  include DocumentsHelper
  include FinancialInformationHelper
  include SharedViewModule
  before_action :check_expired
  
  before_action :dashboard_breadcrumbs, only: [:dashboard]
  before_action :documents_breadcrumbs, only: [:documents]
  before_action :insurance_breadcrumbs, only: [:insurance]
  before_action :taxes_breadcrumbs, only: [:taxes]
  before_action :final_wishes_breadcrumbs, only: [:final_wishes]
  before_action :wills_poa_breadcrumbs, only: [:wills_powers_of_attorney]
  before_action :trusts_entities_breadcrumbs, only: [:trusts_entities]
  before_action :financial_information_breadcrumbs, only: [:financial_information]
  
  include BreadcrumbsCacheModule
  include UserTrafficModule
  before_action :set_shareables
  
  def page_name
    case action_name
      when 'dashboard'
        return "Shared View Dashboard"
      when 'insurance'
        return "Shared Insurance"
      when 'taxes'
        return "Shared Taxes"
      when 'final_wishes'
        return "Shared Final Wishes"
      when 'wills_powers_of_attorney'
        return "Shared Wills & Powers of Attorney"
      when 'trusts_entities'
        return "Shared Trusts & Entities"
      when 'financial_information'
        return "Shared Financial Information"
    end
  end
  
  def dashboard_breadcrumbs
    add_breadcrumb "Dashboard", shared_view_dashboard_path(@shared_user)
  end
  
  def documents_breadcrumbs
    add_breadcrumb "Documents", shared_view_documents_path(@shared_user)
  end
  
  def insurance_breadcrumbs
    add_breadcrumb "Insurance", shared_view_insurance_path(@shared_user)
  end
  
  def taxes_breadcrumbs
    add_breadcrumb "Taxes", shared_view_taxes_path(@shared_user)
  end
  
  def final_wishes_breadcrumbs
    add_breadcrumb "Final Wishes", shared_view_final_wishes_path(@shared_user)
  end
  
  def wills_poa_breadcrumbs
    add_breadcrumb "Wills & Powers of Attorney", shared_view_wills_powers_of_attorney_path(@shared_user)
  end
  
  def trusts_entities_breadcrumbs
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(@shared_user)
  end
  
  def financial_information_breadcrumbs
    add_breadcrumb "Financial Information", shared_view_financial_information_path(@shared_user)
  end
  
  def dashboard
    session[:ret_url] = shared_view_dashboard_path
  end
  
  def insurance
    @category = Category.fetch(Rails.application.config.x.InsuranceCategory.downcase)
    @contacts_with_access = shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @groups = Rails.configuration.x.categories[@category.name]["groups"]
    if @shared_category_names.include? Rails.application.config.x.InsuranceCategory
      @insurance_vendors = Vendor.for_user(shared_user).where(category: @category)
      @insurance_documents = Document.for_user(shared_user).where(category: @category.name)
    else
      @insurance_vendors = @other_shareables.select { |shareable| shareable.is_a?Vendor }
      shared_ids =  @insurance_vendors.map(&:id)
      @insurance_documents = Document.for_user(shared_user).where(:vendor_id => shared_ids)
    end
    session[:ret_url] = shared_view_insurance_path
  end

  def taxes
    @category = Category.fetch(Rails.application.config.x.TaxCategory.downcase)

    @contacts_with_access = @shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
    if @shared_category_names.include? 'Taxes'
      @category_shared = true
      @taxes = TaxYearInfo.for_user(@shared_user)
      @documents = Document.for_user(shared_user).where(category: @category.name)
    else
      tax_year_ids = @other_shareables.select { |shareable| shareable.is_a?Tax }.map(&:tax_year_id).uniq
      @taxes = TaxYearInfo.for_user(@shared_user).where(id: tax_year_ids)
      @documents = Document.for_user(shared_user).where(group: @taxes.map(&:year))
    end
    session[:ret_url] = shared_view_taxes_path
  end

  # GET /final_wishes
  # GET /final_wishes.json
  def final_wishes
    @category = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase)
    @contacts_with_access = @shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    if @shared_category_names.include? 'Final Wishes'
      @category_shared = true
      @final_wishes = FinalWishInfo.for_user(@shared_user)
      @documents = Document.for_user(shared_user).where(category: @category.name)
    else
      final_wish_ids = @other_shareables.select { |shareable| shareable.is_a?FinalWish }.map(&:final_wish_info_id)
      @final_wishes = FinalWishInfo.for_user(@shared_user).where(id: final_wish_ids)
      @documents = Document.for_user(shared_user).where(group: @final_wishes.map(&:group))
    end
    @groups = Rails.configuration.x.categories[@category.name]["groups"]
    @groups.sort_by { |group| group["label"] }
    sort_groups(@final_wishes.map(&:group).sort)
  end
  
  def wills_powers_of_attorney
    @category = Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase)
    if @shared_category_names.include? Rails.application.config.x.WillsPoaCategory
      @power_of_attorney_contacts = PowerOfAttorneyContact.for_user(shared_user)
      @wills = Will.for_user(shared_user)
      @wtl_documents = Document.for_user(shared_user).where(category: Rails.application.config.x.WillsPoaCategory)
    else
      @poa_ids = @other_shareables.select { |shareable| shareable.is_a? PowerOfAttorneyContact }.map(&:id)
      @will_ids = @other_shareables.select { |shareable| shareable.is_a? Will }.map(&:id)
      
      @power_of_attorney_contacts = PowerOfAttorneyContact.for_user(shared_user).where(id: @poa_ids)
      @wills = Will.for_user(shared_user).where(id: @will_ids)
      card_document_ids = @poa_ids.collect { |p_id| CardDocument.power_of_attorney(p_id) }.map(&:id) + 
        @will_ids.collect { |w_id| CardDocument.will(w_id) }.map(&:id)
      @wtl_documents = (Document.for_user(shared_user).where(:card_document_id => card_document_ids) + 
        @document_shareables.select { |d| d.category == @category.name }).uniq
    end
    session[:ret_url] = shared_view_wills_powers_of_attorney_path
  end

  def trusts_entities
    @category = Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase)
    if @shared_category_names.include? Rails.application.config.x.TrustsEntitiesCategory
      @trusts = Trust.for_user(shared_user)
      @entities = Entity.for_user(shared_user)
      @documents = Document.for_user(shared_user).where(category: Rails.application.config.x.TrustsEntitiesCategory)
    else
      @trust_ids = @other_shareables.select { |shareable| shareable.is_a? Trust }.map(&:id)
      @entity_ids = @other_shareables.select { |shareable| shareable.is_a? Entity }.map(&:id)
      
      @trusts = Trust.for_user(shared_user).where(id: @trust_ids)
      @entities = Entity.for_user(shared_user).where(id: @entity_ids)
      card_document_ids = @trust_ids.collect { |t_id| CardDocument.trust(t_id) }.map(&:id) + 
        @entity_ids.collect { |e_id| CardDocument.entity(e_id) }.map(&:id)
      @documents = (Document.for_user(shared_user).where(:card_document_id => card_document_ids) + 
        @document_shareables.select { |d| d.category == @category.name }).uniq
    end
    session[:ret_url] = shared_view_trusts_entities_path
  end
  
  def contacts
    if @shared_category_names.include? Rails.application.config.x.ContactCategory
      contact_service = ContactService.new(:user => shared_user)
      @contacts = contact_service.contacts_shareable
      session[:ret_url] = shared_view_contacts_path
    end
  end

  def documents
    if @shared_category_names.include? Rails.application.config.x.DocumentsCategory
      @documents = Document.for_user(shared_user).each { |d| authorize d }
      session[:ret_url] = shared_view_documents_path
    end
  end

  def card_values(category)
    service = DocumentService.new(:category => category)
    service.get_card_values(shared_user)
  end

  def financial_information
    @category = Rails.application.config.x.FinancialInformationCategory
    if @shared_category_names.include? Rails.application.config.x.FinancialInformationCategory
      @documents = Document.for_user(shared_user).where(category: @category)

      @account_providers = FinancialProvider.for_user(shared_user).type(FinancialProvider::provider_types["Account"])
    
      @alternative_managers = FinancialProvider.for_user(shared_user).type(FinancialProvider::provider_types["Alternative"])

      @investments = FinancialInvestment.for_user(shared_user)
      @properties = FinancialProperty.for_user(shared_user)
      
      @all_cards = (@account_providers + @alternative_managers +
                 @investments + @properties).sort_by!(&:name)
    else
      provider_ids = @other_shareables.select { |shareable| shareable.is_a?FinancialProvider }.map(&:id)
      
      @account_providers = FinancialProvider.for_user(shared_user).type(FinancialProvider::provider_types["Account"]).where(id: provider_ids)
    
      @alternative_managers = FinancialProvider.for_user(shared_user).type(FinancialProvider::provider_types["Alternative"]).where(id: provider_ids)
      
      @properties = FinancialProperty.for_user(shared_user).where(empty_provider_id: provider_ids)
      @investments = FinancialInvestment.for_user(shared_user).where(empty_provider_id: provider_ids)
      
      @all_cards = (@account_providers + @alternative_managers +
                 @investments + @properties).sort_by!(&:name)
      
      @documents = Document.for_user(shared_user).select { |doc| provider_ids.include? doc.financial_information_id }
    end
    session[:ret_url] = shared_view_financial_information_path
  end

  private

  def set_shareables
    if current_user.primary_shared_with?(shared_user)
      @document_shareables = Document.for_user(shared_user)
    else
      @document_shareables, @category_shareables, @other_shareables = Array.new(3) { [] }

      @shares.select(&:shareable_type).map(&:shareable).each do |shareable| 
        case shareable
        when Document
          @document_shareables |= [shareable]
        when Category
          @category_shareables << shareable
        else
          @other_shareables << shareable
        end
      end

      shareables = @shares.select(&:shareable_type).map(&:shareable)
      shared_documents = ShareService.shared_documents(shared_user, current_user)
      @document_shareables |= shared_documents
    end
  end
  
  def sort_groups(existing_group_names)
    all_group_names = @groups.map { |x| x["label"] }
    end_group_names = all_group_names - existing_group_names
    groups = []
    (existing_group_names + end_group_names).each do |group|
      groups.push(@groups.detect { |x| x["label"] == group })
    end
    @groups = groups
  end
  
  def check_expired
    return if @shared_user.corporate_user_by_admin?(current_user)
    if @shared_user.free? || 
        (@shared_user.current_user_subscription &&
          (@shared_user.current_user_subscription.expired_trial? ||
           @shared_user.current_user_subscription.expired_full?))
      redirect_to shared_expired_path(@shared_user)
    end
  end
end
