class FinancialInformationController < AuthenticatedController
  helper_method :cash_sum, :investments_sum, :properties_sum,
                :credit_cards_sum, :loans_sum, :net_worth, :alternatives_sum,
                :uncalled_commitments_sum

  before_action :set_contacts, only: [:add_alternative]
  
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
  end
  
  def alternatives_sum
    FinancialAlternative.alternatives(current_user).sum(:current_value)
  end
  
  def uncalled_commitments_sum
    FinancialAlternative.alternatives(current_user).sum(:total_calls) -
      FinancialAlternative.alternatives(current_user).sum(:commitment)
  end
  
  def cash_sum
    FinancialAccountInformation.cash(current_user).sum(:value)
  end
  
  def investments_sum
    FinancialAccountInformation.investments(current_user).sum(:value) +
      FinancialInvestment.investments(current_user).sum(:value)
  end
  
  def properties_sum
    FinancialProperty.properties(current_user).sum(:value)
  end

  def add_alternative; end
  
  def credit_cards_sum
    FinancialAccountInformation.credit_cards(current_user).sum(:value)
  end
  
  def loans_sum
    FinancialAccountInformation.loans(current_user).sum(:value) + 
      FinancialInvestment.loans(current_user).sum(:value)
  end
  
  def net_worth
    cash_sum + investments_sum + properties_sum - credit_cards_sum - loans_sum + alternatives_sum +
      uncalled_commitments_sum
  end
  
  def value_negative
    return false unless params[:type].present?
    type = params[:type]
    render :json => FinancialInformation::FINANCIAL_INFORMATION_TYPES[:loans].include?(type) ||
                    FinancialInformation::FINANCIAL_INFORMATION_TYPES[:credit_cards].include?(type)
  end
  
  def set_contacts
    @contacts = Contact.for_user(current_user)
  end
end
