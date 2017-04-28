class LifeAndDisabilityPunditPolicy < CategorySharePolicy

  def index?
    owned_or_shared?
  end

  def destroy_provider?
    user_owned?
  end

end
