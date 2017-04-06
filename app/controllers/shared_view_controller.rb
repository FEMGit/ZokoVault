class SharedViewController < AuthenticatedController
  include DocumentsHelper
  include FinancialInformationHelper
  include SharedViewModule
  
  add_breadcrumb "Dashboard", :shared_view_dashboard_path, only: [:dashboard]
  add_breadcrumb "Insurance", :shared_view_insurance_path, only: [:insurance]
  add_breadcrumb "Taxes", :shared_view_taxes_path, only: [:taxes]
  add_breadcrumb "Final Wishes", :shared_view_final_wishes_path, only: [:final_wishes]
  add_breadcrumb "Wills - Power of Attorney", :shared_view_wills_power_of_attorneys_path, only: [:wills_power_of_attorneys]
  add_breadcrumb "Wills - Trusts - Legal", :shared_view_estate_planning_path, only: [:estate_planning]
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, only: [:financial_information]
  
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
        return "Shared Wills - Power of Attorney"
      when 'estate_planning'
        return "Shared Wills - Trusts - Legal"
      when 'financial_information'
        return "Shared Financial Information"
    end
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

  def estate_planning
    @category = Category.fetch(Rails.application.config.x.WtlCategory.downcase)
    if @shared_category_names.include? Rails.application.config.x.WtlCategory
      @wtl_documents = Document.for_user(shared_user).where(category: @category.name)
      @trusts = Trust.for_user(shared_user);
      @wills = Will.for_user(shared_user);
      @power_of_attorneys = PowerOfAttorney.for_user(shared_user);
    else
      @trusts, @wills, @power_of_attorneys, @wtl_documents = [], [], [], []
      groups_whitelist = %w(Trust Will PowerOfAttorney)

      @shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).each do |shareable| 
        case shareable
        when Trust
          @trusts << shareable
          @wtl_documents |= Document.for_user(shared_user).where(:group => Trust.name)
        when Will
          @wills << shareable
          @wtl_documents |= Document.for_user(shared_user).where(:group => Will.name)
        when PowerOfAttorney
          @power_of_attorneys << shareable
          @wtl_documents |= Document.for_user(shared_user).where(:group => 'Legal')
        when Document
          if groups_whitelist.include?shareable.group
            @wtl_documents |= [shareable]
          end
        end
      end
      @vault_entries = [@power_of_attorneys, @trusts, @wills].flatten
      @wtl_documents.flatten!
    end
    session[:ret_url] = shared_view_estate_planning_path
  end

  def documents
    @document = Document.for_user(@shared_user).find(params[:id])
    authorize @document
    @cards = card_values(@document.category)
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
    @document_shareables, @category_shareables, @other_shareables = Array.new(3) { [] }

    @shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).each do |shareable| 
      case shareable
      when Document
        @document_shareables |= [shareable]
      when Category
        @category_shareables << shareable
      else
        @other_shareables << shareable
      end
    end
    
    shareables = @shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable)
    shared_documents = ShareService.shared_documents(shared_user, current_user)
    @document_shareables |= shared_documents
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
end
