class PropertyAndCasualtyPunditPolicy < CategorySharePolicy

  def index?
    owned_or_shared?
  end

  def new?
    owned_or_shared?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def destroy_provider?
    user_owned?
  end

end
