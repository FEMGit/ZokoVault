class DocumentPolicy < BasicPolicy

  def index?
    user_owned?
  end
  
  def create?
    owned_or_shared?
  end

  def documents?
    edit?
  end
  
  def download?
    owned_or_shared?
  end
  
  def preview?
    owned_or_shared?
  end

  def owner_shared_category_with_user?
    shares = policy_share
    return false unless shares
    return true if SharedViewService.shared_categories_full(shares).include? record.try(:category)
    false
  end

  private

  def policy_share
    shared_contact = shared_user.contacts.where(emailaddress: user.email)
    return false unless shared_contact.present?

    shared_user.shares.where(contact: shared_contact)
  end

  def shared_user
    record.user
  end
end
