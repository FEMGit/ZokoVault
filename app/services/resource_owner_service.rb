class ResourceOwnerService
  def self.shared_category_names(owner, user)
    if user.primary_shared_with? owner
      Rails.application.config.x.ShareCategories.dup
    else
      user_contact = owner.contacts.select { |x| x.emailaddress == user.email }
      SharedViewService.shared_categories_full(owner.shares.where(contact: user_contact))
    end
  end
end