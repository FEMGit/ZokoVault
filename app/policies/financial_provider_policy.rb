class FinancialProviderPolicy < CategorySharePolicy

  def destroy_provider?
    user_owned?
  end

end
