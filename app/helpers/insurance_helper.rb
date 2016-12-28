module InsuranceHelper
  def provider_present?(provider)
    provider.webaddress.present? || show_street?(provider) || provider.phone.present? || provider.fax.present? ||
      provider.contact.present? || provider.share_with_contacts.present?
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
end
