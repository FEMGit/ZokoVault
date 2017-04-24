class FinancialProviderPolicy < CategorySharePolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def destroy_provider?
    user_owned?
  end

end
