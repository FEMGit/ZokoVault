class CategorySharePolicy < BasicPolicy
  def index?
    owned_or_shared?
  end
  
  def create?
    owned_or_shared?
  end

  protected 

  def owner_shared_category_with_user?
    Share.exists?(shareable: record.category, contact: Contact.for_user(user))
  end
end
