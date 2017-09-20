class SharePolicy < BasicPolicy

  def index?
    owned_or_shared?
  end

  def download?
    owned_or_shared?
  end
  
  def preview?
    owned_or_shared?
  end

  def create?
    owned_or_shared?
  end
  
  # Online account password reveal
  def reveal_password?
    owned_or_shared?
  end

  # Document add/edit update dropdowns access
  def get_drop_down_options?
    owned_or_shared?
  end
  
  def document_category_share_contacts?
    owned_or_shared?
  end
  
  def document_subcategory_share_contacts?
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
  def documents?; index?; end
  def contacts?; index?; end
  def taxes?; index?; end
  def insurance?; index?; end
  def power_of_attorneys?; index?; end
  def trusts?; index?; end
  def wills?; index?; end
  def online_accounts?; index?; end
  def documents?; index?; end
  def contingent_owner?; index?; end
  
  def mass_document_upload?
    owned_or_shared?
  end
  
  def relationship_values?
    owned_or_shared?
  end

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
    category_names = shares.select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
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
