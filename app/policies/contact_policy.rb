class ContactPolicy < CategorySharePolicy
  def index?
    user_owned?
  end

  def create?
    owned_or_shared?
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
end
