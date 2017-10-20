class FinancialPropertyPolicy < CategorySharePolicy
  def update_balance_sheet?
    owned_or_shared?
  end
  
  def balance_sheet?
    owned_or_shared?
  end
  
  def owner_shared_record_with_user?
    return false if record.nil? || record.empty_provider_id.nil?
    provider = FinancialProvider.find_by(id: record.empty_provider_id)
    Share.exists?(shareable: provider, contact: Contact.where("emailaddress ILIKE ?", user.email))
  end
end
