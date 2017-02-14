class CategorySharePolicy < BasicPolicy
  def index?
    owned_or_shared?
  end
  
  def create?
    owned_or_shared?
  end

  protected 

  def owner_shared_category_with_user?
    shares = policy_share
    return false unless shares
    category_names = shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    return true if record.category.present? && (category_names.include? record.category.name)
    false
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
