class FinancialInformationController < AuthenticatedController
  include SharedViewModule
  include FinancialInformationHelper
  
  add_breadcrumb "Financial Information", :financial_information_path, only: [:index], if: :general_view?
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, only: [:index], if: :shared_view?
  include BreadcrumbsCacheModule
  
  def index
    session[:ret_url] = financial_information_path
    @category = Rails.application.config.x.FinancialInformationCategory
    @documents = Document.for_user(current_user).where(category: @category)
    
    account_provider_ids = FinancialAccountInformation.for_user(current_user).map(&:account_provider_id)
    @account_providers = FinancialProvider.for_user(current_user).find(account_provider_ids)
    
    alternative_manager_ids = FinancialAlternative.for_user(current_user).map(&:manager_id)
    @alternative_managers = FinancialProvider.for_user(current_user).find(alternative_manager_ids)
    
    @investments = FinancialInvestment.for_user(current_user)
    @properties = FinancialProperty.for_user(current_user)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? Category.fetch(@category.downcase) }.map(&:contact) 
  end
  
  def value_negative
    return false unless params[:type].present?
    type = params[:type]
    render :json => FinancialInformation::FINANCIAL_INFORMATION_TYPES[:loans].include?(type) ||
                    FinancialInformation::FINANCIAL_INFORMATION_TYPES[:credit_cards].include?(type)
  end
  
  def property_provider_id(user, property)
    FinancialProvider.for_user(user).find(property.empty_provider_id)
  end
  
  def investment_provider_id(user, investment)
    FinancialProvider.for_user(user).find(investment.empty_provider_id)
  end
end
