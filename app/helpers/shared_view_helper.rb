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
end
