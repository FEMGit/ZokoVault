module AccountsHelper
  def radio_button_checked?(value, mfa_frequency)
    return true if mfa_frequency == value
  end
  
  def family_members_count
    return 0 unless current_user
    Contact.for_user(current_user).where(contact_type: 'Family & Beneficiaries').count
  end
  
  def financial_properties_count
    return 0 unless current_user
    FinancialProperty.for_user(current_user).count
  end
  
  def insurance_vendors_count
    return 0 unless current_user
    Vendor.for_user(current_user).count
  end
  
  def documents_count
    return 0 unless current_user
    Document.for_user(current_user).count
  end
  
  def account_data_any?
    family_members_count > 0 || financial_properties_count > 0 || 
      insurance_vendors_count > 0 || documents_count > 0
  end
end
