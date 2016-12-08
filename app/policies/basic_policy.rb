class BasicPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_owned?
  end

  def show?
    owned_or_shared?
  end

  def create?
    user_owned?
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
    record.user == user
  end

  def shared_with_user?
    owner_shared_account_with_user? || owner_shared_record_with_user?
  end

  def owner_shared_account_with_user?
    Share.exists?(shareable: record.user, contact: Contact.for_user(user))
  end

  def owner_shared_record_with_user?
    Share.exists?(shareable: record, contact: Contact.for_user(user))
  end
end
