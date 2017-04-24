class SharePolicy < BasicPolicy

  def index?
    owned_or_shared?
  end

  def new_wills_poa?
    create?
  end

  def new_trusts_entities?
    create?
  end

  def download?
    owned_or_shared?
  end

  def create?
    owned_or_shared?
  end

  # Document add/edit update dropdowns access
  def get_drop_down_options?
    owned_or_shared?
  end

  def get_card_names?
    owned_or_shared?
  end

  # XXX: Move to SharedViewPolicy
  # Shared view policies
  def dashboard?; index?; end
  def wills_powers_of_attorney?; index? end
  def trusts_entities?; index? end
  def financial_information?; index?; end
  def final_wishes?; index?; end
  def taxes?; index?; end
  def insurance?; index?; end
  def power_of_attorneys?; index?; end
  def trusts?; index?; end
  def wills?; index?; end
  def documents?; index?; end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(contact: Contact.where("emailaddress ILIKE ?", user.email))
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
    category_names = shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) && (sh.shareable.is_a? Category) }.map(&:shareable).map(&:name)
    category_names.include? record.category
  end

  def owner_shared_record_with_user?
    record.contact.try(:emailaddress).try(:downcase) == user.email.downcase
  end

  private

  def policy_share
    shared_contact = Contact.for_user(shared_user).where("emailaddress ILIKE ?", user.email)
    return false unless shared_contact.present?

    shared_user.shares.where(contact: shared_contact)
  end

  def shared_user
    record.user
  end
end
