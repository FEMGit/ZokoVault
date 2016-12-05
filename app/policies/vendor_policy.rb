class VendorPolicy < BasicPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_owned? || shared_with_user?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
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

  private

  def owned_or_shared?
    user_owned? || shared_with_user?
  end

  def user_owned?
    record.user == user
  end

  def shared_with_user?; end
end
