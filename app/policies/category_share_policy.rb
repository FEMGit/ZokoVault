class CategorySharePolicy < BasicPolicy

  protected 

  def owner_shared_category_with_user?
    return false unless record.shared_user_id.present? || record.user_id.present?
    shared_user = User.find(record.shared_user_id || record.user_id)
    shared_contact = Contact.for_user(shared_user).where(emailaddress: user.email)
    return false unless shared_contact.present?

    shares = shared_user.shares.where(contact: shared_contact)
    shared_category_names = shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    shared_category_names.include? record.category.name
  end
end
