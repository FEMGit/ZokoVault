class FinancialProviderPolicy < CategorySharePolicy
  def update_balance_sheet?
    owned_or_shared?
  end
  
  def balance_sheet?
    owned_or_shared?
  end
  
  def destroy_provider?
    user_owned?
  end
end
