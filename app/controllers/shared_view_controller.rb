class SharedViewController < AuthenticatedController
  include DocumentsHelper
  include FinancialInformationHelper
  include SharedViewModule
  
  before_action :set_shared_user, :set_shares, :set_shared_categories_names, :set_category_shared
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
      @insurance_documents = @document_shareables.select { |shareable| @insurance_vendors.map(&:id).include? shareable.vendor_id }
    end
    session[:ret_url] = shared_view_insurance_path
  end

  def taxes
    @category = Category.fetch(Rails.application.config.x.TaxCategory.downcase)

    @contacts_with_access = @shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @taxes = 
      if @shared_category_names.include? 'Tax'
        TaxYearInfo.for_user(@shared_user)
      else
        @other_shareables.map { |shareable| shareable.is_a?TaxYearInfo }
      end
    @documents = @document_shareables.select { |x| x.category == @category.name}
  end

  # GET /final_wishes
  # GET /final_wishes.json
  def final_wishes
    @category = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase)
    @contacts_with_access = @shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @final_wishes =
      if @shared_category_names.include? 'Final Wishes'
        FinalWishInfo.for_user(@shared_user)
      else
        @other_shareables.map { |shareable| shareable.is_a?FinalWishInfo }
      end
    @documents = @document_shareables.select { |x| x.category == @category.name}
  end

  def estate_planning
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
      @vault_entries = [@power_of_attorneys, @trusts, @wills].flatten
      @wtl_documents.flatten!
    end
    @category = Rails.application.config.x.WtlCategory
    session[:ret_url] = shared_view_estate_planning_path
  end

  def trusts
    shareables = @shares.map(&:shareable)
    @trusts = shareables.select { |resource| resource.is_a? Trust }
    @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "Trust" }
  end

  def power_of_attorneys
    shareables = @shares.map(&:shareable)
    @power_of_attorneys = shareables.select { |resource| resource.is_a? PowerOfAttorney }
    @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "PowerOfAttorney" }
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
    if @shared_category_names.include? Rails.application.config.x.InsuranceCategory
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
      
      investment_ids = @other_shareables.select { |shareable| shareable.is_a?FinancialInvestment }.map(&:id)
      property_ids = @other_shareables.select { |shareable| shareable.is_a?FinancialProperty }.map(&:id)

      
      @investments = FinancialInvestment.for_user(shared_user).where(id: investment_ids) +
                     FinancialInvestment.for_user(shared_user).where(empty_provider_id: provider_ids)
      @properties = FinancialProperty.for_user(shared_user).where(id: property_ids) + 
                    FinancialProperty.for_user(shared_user).where(empty_provider_id: provider_ids)
      
      @documents = Document.for_user(shared_user).select { |doc| provider_ids.include? doc.financial_information_id }
    end
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
  end
end
