module FinancialInformationHelper
  def uniq_account_types
    FinancialAccountInformation.for_user(resource_owner).flat_map(&:account_type).uniq
  end
  
  def path_to_resource(financial_provider)
    if FinancialAccountInformation.find_by(account_provider_id: financial_provider.id)
      show_account_path(financial_provider)
    elsif FinancialAlternative.find_by(manager_id: financial_provider.id)
      show_alternative_path(financial_provider)
    elsif FinancialInvestment.find_by(empty_provider_id: financial_provider.id)
      investment = FinancialInvestment.find_by(empty_provider_id: financial_provider.id)
      show_investment_path(investment)
    elsif FinancialProperty.find_by(empty_provider_id: financial_provider.id)
      property = FinancialProperty.find_by(empty_provider_id: financial_provider.id)
      show_property_path(property)
    end
  end
  
  def financial_provider_account?(provider)
    provider.provider_type.eql? "Account"
  end
  
  def financial_provider_alternative?(provider)
    provider.provider_type.eql? "Alternative"
  end
  
  def financial_information_any?
    FinancialAccountInformation.for_user(resource_owner).any? ||
      FinancialInvestment.for_user(resource_owner).any? ||
      FinancialAlternative.for_user(resource_owner).any? ||
      FinancialProperty.for_user(resource_owner).any? ||
      FinancialProvider.for_user(resource_owner).any?
  end
  
  def financial_provider(empty_provider_object)
    FinancialProvider.find_by(id: empty_provider_object.empty_provider_id)
  end
  
  def show_financial_provider_address?(provider)
    provider.street_address.present? && provider.city.present? &&
      provider.state.present?
  end
  
  def show_financial_property_address?(property)
    property.address.present? && property.city.present? &&
      property.state.present?
  end
  
  def financial_provider_present?(provider)
    provider.web_address.present? || provider.phone_number.present? || provider.fax_number.present? ||
      provider.primary_contact.present? || category_subcategory_shares(provider, provider.user).present? || show_financial_provider_address?(provider)
  end
  
  def financial_account_present?(account)
    account.account_owners.any? || account.value.present? || account.number.present? ||
      account.primary_contact_broker.present? || account.notes.present? || account.name.present?
  end
  
  def financial_property_present?(property)
    provider = financial_provider(property)
    property.property_owners.any? || property.value.present? || show_financial_property_address?(property) ||
      property.primary_contact.present? || property.notes.present? || category_subcategory_shares(provider, provider.user).present?
  end
  
  def financial_alternative_present?(alternative)
    alternative.owner.present? || alternative.total_calls.present? || alternative.total_distributions.present? ||
      alternative.current_value.present? || alternative.commitment.present? || alternative.primary_contact.present? ||
      alternative.notes.present?
  end
  
  def financial_investment_present?(investment)
    provider = financial_provider(investment)
    investment.owner.present? || investment.value.present? || show_financial_property_address?(investment) ||
      investment.web_address.present? || investment.phone_number.present? || investment.primary_contact.present? ||
      investment.notes.present? || category_subcategory_shares(provider, provider.user).present?
  end
  
  def value_negative?(type)
    FinancialInformation::FINANCIAL_INFORMATION_TYPES[:loans].include?(type) ||
      FinancialInformation::FINANCIAL_INFORMATION_TYPES[:credit_cards].include?(type)
  end
  
  def commitments_show?
    FinancialAlternative.for_user(resource_owner).any?
  end

  def credit_card_show?
    (uniq_account_types - FinancialInformation.credit_card_types).length < uniq_account_types.length
  end
  
  # Sum count section
  
  def property_provider_id(user, property)
    FinancialProvider.for_user(user).find(property.empty_provider_id)
  end
  
  def investment_provider_id(user, investment)
    FinancialProvider.for_user(user).find(investment.empty_provider_id)
  end
  
  def alternatives_sum
    FinancialAlternative.alternatives(resource_owner).sum(:current_value)
  end
  
  def uncalled_commitments_sum
    FinancialAlternative.alternatives(resource_owner).sum(:total_calls) -
      FinancialAlternative.alternatives(resource_owner).sum(:commitment)
  end
  
  def cash_sum
    FinancialAccountInformation.cash(resource_owner).sum(:value)
  end
  
  def investments_sum
    FinancialAccountInformation.investments(resource_owner).sum(:value) +
      FinancialInvestment.investments(resource_owner).sum(:value)
  end
  
  def properties_sum
    FinancialProperty.properties(resource_owner).sum(:value)
  end
  
  def credit_cards_sum
    FinancialAccountInformation.credit_cards(resource_owner).sum(:value)
  end
  
  def loans_sum
    FinancialAccountInformation.loans(resource_owner).sum(:value) + 
      FinancialInvestment.loans(resource_owner).sum(:value)
  end
  
  def net_worth
    cash_sum + investments_sum + properties_sum - credit_cards_sum - loans_sum + alternatives_sum
  end
  
  # Part percentage section
    
  def investment_parts
    investment_part = fill_part_percentage(FinancialInvestment.investments(resource_owner).group_by(&:investment_type), investments_sum)
    account_part = fill_part_percentage(FinancialAccountInformation.investments(resource_owner).group_by(&:account_type), investments_sum)
    investment_part.merge(account_part)
  end
  
  def property_parts
    fill_part_percentage(FinancialProperty.properties(resource_owner).group_by(&:property_type), properties_sum)
  end
  
  def cash_parts
    fill_part_percentage(FinancialAccountInformation.cash(resource_owner).group_by(&:account_type), cash_sum)
  end
  
  def alternative_parts
    fill_part_percentage_alternative(FinancialAlternative.alternatives(resource_owner).group_by(&:alternative_type), alternatives_sum)
  end
  
  def credit_card_parts
    fill_part_percentage(FinancialAccountInformation.credit_cards(resource_owner).group_by(&:account_type), credit_cards_sum)
  end
  
  def loan_parts
    account_part = fill_part_percentage(FinancialAccountInformation.loans(resource_owner).group_by(&:account_type), loans_sum)
    investment_part = fill_part_percentage(FinancialInvestment.loans(resource_owner).group_by(&:investment_type), loans_sum)
    account_part.merge(investment_part)
  end
  
  def resource_owner
    @shared_user.present? ? @shared_user : current_user
  end
  
  private 
  
  def fill_part_percentage(collection, sum)
    collection.each_with_object({}) do |(type, values), hsh|
      hsh[type] = (values.flatten.reject { |v| v.value.blank? }.sum(&:value).to_f / sum.to_f * 100).round(1)
    end
  end
  
  def fill_part_percentage_alternative(collection, sum)
    collection.each_with_object({}) do |(type, values), hsh|
      hsh[type] = (values.flatten.reject { |v| v.current_value.blank? }.sum(&:current_value).to_f / sum.to_f * 100).round(1)
    end
  end
end
