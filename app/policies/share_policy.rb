class SharePolicy < BasicPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    owned_or_shared?
  end


  # XXX: Move to SharedViewPolicy
  # Shared view policies
  def dashboard?; index?; end
  def estate_planning?; index?; end
  def final_wishes?; index?; end
  def taxes?; index?; end
  def insurance?; index?; end
  def power_of_attorneys?; index?; end
  def trusts?; index?; end
  def wills?; index?; end

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
      scope.where(contact: Contact.where(emailaddress: user.email))
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
    false
  end

  def owner_shared_record_with_user?
    record.contact.try(:emailaddress) == user.email
  end
end
