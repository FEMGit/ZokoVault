class HealthPunditPolicy < CategorySharePolicy

  def index?
    owned_or_shared?
  end

  def destroy_provider?
    user_owned?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

end
