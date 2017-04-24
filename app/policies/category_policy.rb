class CategoryPolicy < BasicPolicy

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected

  def user_owned?
    user.admin?
  end

  def owned_or_shared?
    user_owned? || shared_with_user?
  end

  def shared_with_user?
    false
  end
end
