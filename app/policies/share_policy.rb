class SharePolicy < BasicPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    owned_or_shared?
  end
  
  def create?
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
  def documents?; index?; end

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
    owner_shared_account_with_user? || owner_shared_record_with_user? ||
      owner_shared_category_with_user?
  end

  def owner_shared_account_with_user?
    false
  end
  
  def owner_shared_category_with_user?
    shares = policy_share
    return false unless shares
    category_names = shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    category_names.include? record.category
  end

  def owner_shared_record_with_user?
    record.contact.try(:emailaddress) == user.email
  end
  
  private
  
  def policy_share
    shared_contact = Contact.for_user(shared_user).where(emailaddress: user.email)
    return false unless shared_contact.present?

    shared_user.shares.where(contact: shared_contact)
  end
  
  def shared_user
    record.user
  end
end
