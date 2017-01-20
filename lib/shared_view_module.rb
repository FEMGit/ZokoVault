module SharedViewModule
  def self.included(base)
    base.before_filter :set_shared_user, :set_shares, :set_shared_categories_names, :set_category_shared
    base.layout :set_layout, only: [:new, :edit, :index, :show]
  end
  
  def set_layout
    unless resource_owner == current_user
      return "shared_view"
    end
    "application"
  end
  
  def set_shared_user
    return unless params[:shared_user_id].present?
    @shared_user = User.find(params[:shared_user_id])
  end

  def shared_user
    return unless params[:shared_user_id].present?
    @shared_user
  end

  def set_shares
    return unless params[:shared_user_id].present?
    @shares = policy_scope(Share).where(user: @shared_user).each { |s| authorize s }
  end

  def set_shared_categories_names
    return unless params[:shared_user_id].present?
    @shared_category_names = @shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    @shared_category_names_full = SharedViewService.shared_categories_full(@shares)
  end
  
  def set_category_shared
    return unless params[:shared_user_id].present?
    @category_shared = false
  end
end