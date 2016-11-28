class BasicPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    owned_or_shared?
  end

  def create?
    owned_or_shared?
  end

  def new?
    create?
  end

  def update?
    owned_or_shared?
  end

  def edit?
    update?
  end

  def destroy?
    user_owned?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def scoped_record_exists?
    scope.where(:id => record.id).exists?
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

  protected

  def owned_or_shared?
    user_owned? || shared_with_user?
  end

  def user_owned?
    false
  end

  def shared_with_user?
    false
  end
end
