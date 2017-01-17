class SharedViewControllerBase < AuthenticatedController
  before_action :set_shared_user, :set_shares, :set_shared_categories_names, :set_category_shared
  layout "shared_view"
  
  protected
  def set_shared_user 
    @shared_user = User.find(params[:shared_user_id])
  end

  def shared_user
    @shared_user
  end

  def set_shares
    @shares = policy_scope(Share).where(user: @shared_user).each { |s| authorize s }
  end

  def set_shared_categories_names
    @shared_category_names = @shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    @shared_category_names_full = SharedViewService.shared_categories_full(@shares)
  end
  
  def set_category_shared
    @category_shared = false
  end
  
  def set_contacts
    contact_service = ContactService.new(:user => shared_user)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end
end