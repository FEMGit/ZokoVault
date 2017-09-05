module SharedViewModule
  @@primary_shared_with_category_names = [Rails.application.config.x.DocumentsCategory, Rails.application.config.x.ContactsCategory].freeze
  
  def self.included(base)
    base.before_filter :set_shared_user, :set_shares, :set_shared_categories_names, :set_category_shared
    base.layout :set_layout, only: [:new, :new_wills_poa, :new_trusts_entities, :edit, :index, :show]
  end
  
  def self.primary_shared_with_category_names
    @@primary_shared_with_category_names
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
    @shares = policy_scope(Share.includes(:user, :contact)).where(user: @shared_user).each { |s| authorize s }
  end

  def set_shared_categories_names
    return unless params[:shared_user_id].present?
    if current_user.primary_shared_with?(shared_user)
      @shared_category_names = Rails.application.config.x.ShareCategories.dup
      @shared_category_names_full = Rails.application.config.x.ShareCategories.dup
    else
      @shared_category_names = @shares.select(&:shareable_type)
                                      .select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name) - @@primary_shared_with_category_names
      @shared_category_names_full = SharedViewService.shared_categories_full(@shares) - @@primary_shared_with_category_names
    end
  end

  def set_category_shared
    return unless params[:shared_user_id].present?
    @category_shared = false
  end
end
