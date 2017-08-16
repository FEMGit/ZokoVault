class FinancialInformationController < AuthenticatedController
  include SharedViewModule
  include FinancialInformationHelper
  include TutorialsHelper
  include CategoriesHelper
  
  add_breadcrumb "Financial Information", :financial_information_path, only: [:index], if: :general_view?
  add_breadcrumb "Financial Information", :shared_view_financial_information_path, only: [:index], if: :shared_view?
  include BreadcrumbsCacheModule
  include UserTrafficModule
  
  def page_name
    case action_name
      when 'index'
        return "Financial Information"
    end
  end
  
  def index
    session[:ret_url] = financial_information_path
    @category = Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase)
    set_tutorial_in_progress(financial_information_empty?)
    @documents = Document.for_user(current_user).where(category: @category.name)
    
    @account_providers = FinancialProvider.for_user(current_user).type(FinancialProvider::provider_types["Account"])
    
    @alternative_managers = FinancialProvider.for_user(current_user).type(FinancialProvider::provider_types["Alternative"])
    
    @investments = FinancialInvestment.for_user(current_user)
    @properties = FinancialProperty.for_user(current_user)
    
    @all_cards = (@account_providers + @alternative_managers +
                 @investments + @properties).sort_by!(&:name)
    @contacts_with_access = current_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 
  end
  
  def balance_sheet
    set_financial_information_resources
  end
  
  def update_balance_sheet
    update_value(:account, FinancialAccountInformation, :value)
    update_value(:alternative, FinancialAlternative, :current_value)
    update_value(:property, FinancialProperty, :value)
    update_value(:investment, FinancialInvestment, :value)
    
    respond_to do |format|
      if params[:is_tutorial].present? && params[:is_tutorial].eql?('true')
        tutorial_redirection(format, @financial_provider.as_json)
      else
        format.html { redirect_to financial_information_path, flash: { success: 'Balance Sheet was successfully updated.' } }
      end
    end
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
  
  private
  
  def balance_sheet_params(type)
    return [] unless params[:financial_provider].present?
    params[:financial_provider].select { |k, _v| k.include? "#{type.to_s}_" }.collect { |k, v| [k[/\d+/], v] }
  end
  
  def update_value(type, model, value_name)
    balance_sheet_params(type).each do |id, value|
      next unless (account = model.find_by(id: id)).present?
      account.update_attribute(value_name, value)
    end
  end
  
  # Tutorial workflow integrated
  
  def set_tutorial_resources
    @financial_advisors = Contact.for_user(resource_owner).where(relationship: 'Financial Advisor / Broker', contact_type: 'Advisor')
    @contact = Contact.new(user: resource_owner)
  end
end
