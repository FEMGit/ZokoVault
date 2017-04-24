class WillPolicy < CategorySharePolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def update_wills?
    update?
  end

  def new_wills_poa?
    create?
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
