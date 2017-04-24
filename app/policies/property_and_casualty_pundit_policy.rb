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

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
