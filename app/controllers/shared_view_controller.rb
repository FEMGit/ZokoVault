class SharedViewController < AuthenticatedController
  include DocumentsHelper
  include FinancialInformationHelper
  include SharedViewModule
  
  add_breadcrumb "Insurance", :shared_view_insurance_path, only: [:insurance]
  add_breadcrumb "Taxes", :shared_view_taxes_path, only: [:taxes]
  add_breadcrumb "Final Wishes", :shared_view_final_wishes_path, only: [:final_wishes]
  add_breadcrumb "Wills - Trusts - Legal", :shared_view_estate_planning_path, only: [:estate_planning]
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, only: [:financial_information]
  
  include BreadcrumbsCacheModule
  before_action :set_shareables
  
  def dashboard
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

      @shares.map(&:shareable).each do |shareable| 
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

      account_provider_ids = FinancialAccountInformation.for_user(shared_user).map(&:account_provider_id)
      @account_providers = FinancialProvider.for_user(shared_user).find(account_provider_ids)

      alternative_manager_ids = FinancialAlternative.for_user(shared_user).map(&:manager_id)
      @alternative_managers = FinancialProvider.for_user(shared_user).find(alternative_manager_ids)

      @investments = FinancialInvestment.for_user(shared_user)
      @properties = FinancialProperty.for_user(shared_user)
    else
      provider_ids = @other_shareables.select { |shareable| shareable.is_a?FinancialProvider }.map(&:id)
      
      account_provider_ids = FinancialAccountInformation.for_user(shared_user).where(account_provider_id: provider_ids).map(&:account_provider_id)
      @account_providers = FinancialProvider.where(id: account_provider_ids)
      
      alternative_manager_ids = FinancialAlternative.for_user(shared_user).where(manager_id: provider_ids).map(&:manager_id)
      @alternative_managers = FinancialProvider.where(id: alternative_manager_ids)
      
      @properties = FinancialProperty.for_user(shared_user).where(empty_provider_id: provider_ids)
      @investments = FinancialInvestment.for_user(shared_user).where(empty_provider_id: provider_ids)
      
      @documents = Document.for_user(shared_user).select { |doc| provider_ids.include? doc.financial_information_id }
    end
    session[:ret_url] = shared_view_financial_information_path
  end

  private

  def set_shareables
    @document_shareables, @category_shareables, @other_shareables = Array.new(3) { [] }

    @shares.map(&:shareable).each do |shareable| 
      case shareable
      when Document
        @document_shareables |= [shareable]
      when Category
        @category_shareables << shareable
      else
        @other_shareables << shareable
      end
    end
    
    shareables = @shares.map(&:shareable)
    direct_document_share = shareables.select { |res| res.is_a? Document }
    group_docs = Document.for_user(shared_user).select { |x| shared_groups(shared_user).include? x.group }
    vendor_docs = Document.for_user(shared_user).select { |x| shared_groups(shared_user).include? x.vendor_id }
    financial_docs = Document.for_user(shared_user).select { |x| shared_groups(shared_user).include? x.financial_information_id }
    category_docs = Document.for_user(shared_user).select { |x| shared_categories(shared_user).include? x.category }
    @document_shareables |= (group_docs + direct_document_share + category_docs + vendor_docs + financial_docs).uniq
  end
    
  def shared_groups(user)
    SharedViewService.shared_group_names(user, current_user)
  end
  
  def shared_categories(user)
    SharedViewService.shares(user, current_user).map(&:shareable).select  { |res| res.is_a? Category }.map(&:name)
  end
end
