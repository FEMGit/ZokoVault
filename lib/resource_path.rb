module ResourcePath
  include ApplicationHelper
  include FinancialInformationHelper
  def absolute_path(relative_path)
    root_url.chomp('/') + relative_path
  end
  
  def resource_link(resource, user = current_user)
    return nil unless resource
    if resource.is_a? Contact
      profile_for_current_user = UserProfile.find_by(user_id: user.id)
      if resource.user_profile_id.present? && (resource.user_profile_id.eql? profile_for_current_user.id)
        return user_profiles_path
      else
        return url_for(resource)
      end
    end
    
    if resource.is_a? Category
      return category_view_path(resource)
    end
    
    if subcategory_view_path(resource).present?
      subcategory_view_path(resource)
    elsif resource.try(:attributes)
      url_for_resource_with_arrtibutes(resource)
    else
      url_for(resource[:path])
    end
  end
  
  def url_for_resource_with_arrtibutes(resource)
    case resource
      when FinancialProvider
        case resource.provider_type
          when "Account"
            financial_account_path(resource)
          when "Alternative"
            financial_alternative_path(resource)
        end
      when FinancialInvestment
        financial_investment_path(resource)
      when FinancialProperty
        financial_property_path(resource)
      else
        url_for(resource)
    end
  end
end
