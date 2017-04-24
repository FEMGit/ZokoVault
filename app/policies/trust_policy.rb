class TrustPolicy < CategorySharePolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def update_trusts?
    update?
  end

  def new_trusts_entities?
    create?
  end

end
