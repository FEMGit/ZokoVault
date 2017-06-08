module InsuranceHelper
  def provider_present?(provider)
    provider.webaddress.present? || show_street?(provider) || provider.phone.present? || provider.fax.present? ||
      provider.contact.present? || category_subcategory_shares(provider, provider.user).present?
  end
  
  def provider_main_page_present?(provider)
    provider.webaddress.present? || provider.phone.present?
  end
  
  def life_policy_present?(policy)
    policy.coverage_amount.present? || policy.policy_holder.present? || policy.policy_number.present? || policy.primary_beneficiaries.present? ||
      policy.secondary_beneficiaries.present? || policy.broker_or_primary_contact.present? || policy.notes.present?
  end
  
  def health_policy_present?(policy)
    policy.policy_number.present? || policy.insured_members.present? ||
      policy.broker_or_primary_contact.present? || policy.notes.present? || policy.group_id.present?
  end
  
  def property_policy_present?(policy)
    policy.coverage_amount.present? || policy.policy_number.present? || policy.policy_holder.present? ||
      policy.broker_or_primary_contact.present? || policy.notes.present?
  end
  
  def insurance_edit_path(card, shared_user = nil)
    case card
      when LifeAndDisability
        return edit_life_path(card) unless shared_user
        shared_edit_life_path(shared_user, card)
      when PropertyAndCasualty
        return edit_property_path(card) unless shared_user
        shared_edit_property_path(shared_user, card)
      when Health
        return edit_health_path(card) unless shared_user
        shared_edit_health_path(shared_user, card)
    end
  end
  
  def insurance_delete_path(path, data)
    if path.include? lives_path
      return delete_life_provider_path(data) if path.include? 'provider'
      life_path(data)
    elsif path.include? properties_path
      return delete_property_provider_path(data) if path.include? 'provider'
      property_path(data)
    elsif path.include? healths_path
      return delete_health_provider_path(data) if path.include? 'provider'
      health_path(data)
    end
  end
end
