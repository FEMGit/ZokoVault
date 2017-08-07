class ContactPolicy < BasicPolicy

  def index?
    user_owned?
  end

  def create?
    user_owned? || owner_shared_category_with_user?
  end
  
  def show?
    super || corporate_permitted?
  end

  def new?
    super || corporate_permitted?
  end

  def update?
    super || corporate_permitted?
  end

  def edit?
    super || corporate_permitted?
  end

  private
  
  def corporate_permitted?
    return false unless user.corporate_employee?
    user.employee_users.map(&:email).include? record.emailaddress
  end

  def owner_shared_category_with_user?
    shared_contact = Contact.for_user(record.user).where(emailaddress: user.email)
    return false unless shared_contact.present?
    shares = record.user.shares.where(contact: shared_contact)

    return false unless shares
    return true if SharedViewService.shared_categories_full(shares).any?
    false
  end
end
