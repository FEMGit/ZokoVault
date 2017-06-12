module SharedViewHelper
  def shared_category_path(category_name, user)
    case category_name
    when Rails.application.config.x.FinalWishesCategory
      link_to 'View Category', shared_view_final_wishes_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.TaxCategory
      link_to 'View Category', shared_view_taxes_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.InsuranceCategory
      link_to 'View Category', shared_view_insurance_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.WillsPoaCategory
      link_to 'View Category', shared_view_wills_powers_of_attorney_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.TrustsEntitiesCategory
      link_to 'View Category', shared_view_trusts_entities_path(@shared_user), class: 'view-category'
    when Rails.application.config.x.ContactCategory
      link_to 'View Category', shared_view_contacts_path(@shared_user), class: 'view-category'
    end
  end
  
  def category_name(category)
    if category.eql? Rails.application.config.x.WillsPoaCategory
      "Wills & Powers of Attorney"
    else
      category
    end
  end
  
  def category_shared?(owner, category)
    return true if owner == current_user
    @shared_category_names.include? category
  end
  
  def category_shared_full?(owner, category)
    return true if owner == current_user
    @shared_category_names_full.include? category
  end
  
  def subcategory_shared?(owner, non_owner, document)
    return true if current_user.primary_shared_with_or_owner?(owner)
    service = DocumentService.new(:category => document.category)
    card_values = service.get_card_values(owner, non_owner).flatten(2).collect{ |x| x[:id] }
    card_names = service.get_card_names(owner, non_owner).flatten(2).collect{ |x| x[:id] }

    if (card_values.any? { |x| document.group == x } && document.vendor_id.blank? && document.financial_information_id.blank?) || 
       (document.category == Rails.application.config.x.InsuranceCategory && card_names.any? { |x| document.vendor_id == x}) ||
       (document.category == Rails.application.config.x.FinancialInformationCategory && card_names.any? { |x| document.financial_information_id == x}) ||
       (document.category == Rails.application.config.x.WillsPoaCategory && card_names.any? { |x| document.card_document_id == x}) ||
       (document.category == Rails.application.config.x.TrustsEntitiesCategory && card_names.any? { |x| document.card_document_id == x})
      return true
    end
    false
  end
  
  def show_navigation_link?(category)
    @shared_category_names_full.include? category
  end
  
  def show_add_link?(owner, non_owner, category, subcategory)
    return true if owner.nil?
    groups = SharedViewService.shared_group_names(owner, non_owner)
    groups[category_shareable_type_transform(category)].include? subcategory
  end
  
  def show_insurance_info?(owner, vendors, vendor_group)
    return true if owner == current_user
    vendors.select { |v| v.group.eql? vendor_group }.count > 0
  end
  
  def category_shareable_type_transform(category)
    case category
    when Rails.application.config.x.FinalWishesCategory
      "FinalWish"
    when Rails.application.config.x.TaxCategory
      "Tax"
    when Rails.application.config.x.InsuranceCategory
      "Vendor"
    when Rails.application.config.x.WillsPoaCategory
      "Will - POA"
    when Rails.application.config.x.TrustsEntitiesCategory
      "Trusts & Entities"
    when Rails.application.config.x.FinancialInformationCategory
      "FinancialProvider"
    end
  end
  
  def full_category_shares(category, owner)
    return [] if owner.nil?
    owner.shares.reject{ |x| x.shareable_type.nil? }.select { |sh| sh.shareable == category }
  end
  
  def category_subcategory_shares(object, owner)
    return [] if object.try(:shares).nil? && object.all? { |x| x.respond_to?('each') }
    obj_shares = object.try(:shares) || object.map(&:shares).flatten.uniq
    category = object.try(:category) || object.try(:first).try(:category)
    return obj_shares.flatten if category.nil? || owner.nil?
    category_shares = owner.shares.reject{ |x| x.shareable_type.nil? }.select { |sh| sh.shareable == category }
    return obj_shares.flatten if category_shares.nil?
    (obj_shares + category_shares).uniq(&:contact_id).reject { |sh| sh.contact_id.zero? }
  end
end
