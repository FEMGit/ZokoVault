class TrustPolicy < CategorySharePolicy

  def update_trusts?
    update?
  end

  def new_trusts_entities?
    create?
  end

end
