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
  
  def remove_corporate_client?
    user_account = User.find_by(email: record.try(:emailaddress))
    user_account.corporate_client? && user.corporate_admin && user_account.corporate_user_by_admin?(user)
  end

  private
  
  def corporate_permitted?
    return false unless user.corporate_employee?
    user.employee_users.map(&:email).include? record.emailaddress
  end

  def owner_shared_category_with_user?
    shared_contact = record.user.contacts.where(emailaddress: user.email).first
    return false if shared_contact.blank?
    shares = record.user.shares.where(contact: shared_contact).to_a
    return false if shares.blank?
    return true if SharedViewService.shared_categories_full(shares).any?
    false
  end
end
