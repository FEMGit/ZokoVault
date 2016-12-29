class CategorySharePolicy < BasicPolicy

  protected 

  def owner_shared_category_with_user?
    Share.exists?(shareable: record.category, contact: Contact.for_user(user))
  end
end
