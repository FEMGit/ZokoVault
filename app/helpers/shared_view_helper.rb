module SharedViewHelper
  def shared_category_path(category_name, user)
    case category_name
    when Rails.application.config.x.FinalWishesCategory
      link_to 'View Category', shared_view_final_wishes_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.TaxCategory
      link_to 'View Category', shared_view_taxes_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.InsuranceCategory
      link_to 'View Category', shared_view_insurance_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.WtlCategory
      link_to 'View Category', shared_view_estate_planning_path(@shared_user), class: 'view-category'
    end
  end
  
  def show_navigation_link?(category)
    @shared_category_names_full.include? category
  end
  
  def show_add_link?(owner, non_owner, category, subcategory)
    return true if owner.nil?
    SharedViewService.shared_group_names(owner, non_owner, category).include? subcategory
  end
  
  def full_category_shares(category, owner)
    owner.shares.select { |sh| sh.shareable == category }
  end
  
  def category_subcategory_shares(object, owner)
    obj_shares = object.try(:shares) || object.map(&:shares).flatten.uniq
    category = object.try(:category) || object.first.try(:category)
    return unless category.present?
    category_shares = owner.shares.select { |sh| sh.shareable == category }
    return obj_shares unless category_shares.present?
    (obj_shares + category_shares).uniq(&:contact_id)
  end
end
