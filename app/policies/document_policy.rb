class DocumentPolicy < BasicPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_owned?
  end
  
  def create?
    owned_or_shared? || owner_shared_subcategory_with_user?
  end

  def documents? 
    edit?
  end
  
  def owner_shared_subcategory_with_user?
    shares = policy_share
    return false unless shares
    SharedViewService.shared_categories_full(shares).include? record.category
  end
  
  def owner_shared_category_with_user?
    shares = policy_share
    return false unless shares
    shared_category_names = shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    return true if shared_category_names.include? record.category
    unless shared_category_names.include? record.category
      Rails.configuration.x.ShareCategories.each do |category|
        return true if SharedViewService.shared_group_names(shared_user, user, category).include? record.group
      end
    end
    false
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
  
  def policy_share
    shared_contact = Contact.for_user(shared_user).where(emailaddress: user.email)
    return false unless shared_contact.present?

    shared_user.shares.where(contact: shared_contact)
  end
  
  def shared_user
    record.user
  end
end
