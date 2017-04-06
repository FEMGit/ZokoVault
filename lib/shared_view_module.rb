module SharedViewModule
  def self.included(base)
    base.before_filter :set_shared_user, :set_shares, :set_shared_categories_names, :set_category_shared
    base.layout :set_layout, only: [:new, :new_wills_poa, :edit, :index, :show]
  end
  
  def shared_view?
    @shared_user.present?
  end
  
  def general_view?
    !@shared_user.present?
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
    @shared_category_names = @shares.select(&:shareable_type)
                                    .select { |sh| Object.const_defined?(sh.shareable_type) && (sh.shareable.is_a? Category) }.map(&:shareable).map(&:name)
    @shared_category_names_full = SharedViewService.shared_categories_full(@shares)
  end
  
  def set_category_shared
    return unless params[:shared_user_id].present?
    @category_shared = false
  end
end