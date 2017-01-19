class ResourceOwnerService
  def self.shared_category_names(owner, user)
    user_contact = Contact.for_user(owner).select { |x| x.emailaddress == user.email }
    SharedViewService.shared_categories_full(owner.shares.where(contact: user_contact))
  end
end