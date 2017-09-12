class ToDoPopupModal
  extend CategoriesHelper
  
  BASE = 'to_do_popup_modals/'
  CATEGORY_POPUP = {
    "Vault Inheritance" => 'vault_inheritance_modal',
    "Vault Co-Owner" => 'vault_co_owner_modal',
    Rails.application.config.x.OnlineAccountCategory => 'online_accounts_modal',
    Rails.application.config.x.FinalWishesCategory => 'final_wishes_modal',
    Rails.application.config.x.FinancialInformationCategory => 'financial_information_modal',
    Rails.application.config.x.WillsPoaCategory => 'wills_and_powers_of_attorney_modal',
    Rails.application.config.x.TrustsEntitiesCategory => 'trusts_and_entities_modal',
    Rails.application.config.x.InsuranceCategory => 'insurance_modal',
    Rails.application.config.x.TaxCategory => 'taxes_modal'
  }
  
  def self.random_popup_modal(user:)
    return nil unless user && user.login_count && user.login_count > 1
    return nil if user.free? || user.corporate_manager? || user.corporate_user?
    categories = popup_categories(user: user)
    return nil unless (random_modal_name = CATEGORY_POPUP.select { |key, value| categories.include? key }.values.sample)
    BASE + random_modal_name
  end
  
  def self.popup_name_by_route(path:)
    CATEGORY_POPUP.invert[path.remove(BASE)]
  end
  
  private
  
  def self.popup_categories(user: user)
    cancelled_categories = ToDoPopupCancel.find_or_initialize_by(user: user).cancelled_popups
    popup_categories = []
    check_and_push(name: 'Vault Inheritance', is_empty: vault_inheritance_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: 'Vault Co-Owner', is_empty: vault_co_owner_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.OnlineAccountCategory, is_empty: online_accounts_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.FinalWishesCategory, is_empty: final_wishes_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.FinancialInformationCategory, is_empty: financial_information_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.WillsPoaCategory, is_empty: wills_poa_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.TrustsEntitiesCategory, is_empty: trusts_entities_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.InsuranceCategory, is_empty: insurance_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    check_and_push(name: Rails.application.config.x.TaxCategory, is_empty: taxes_empty?(user),
                   cancelled_categories: cancelled_categories, current_popup_categories: popup_categories)
    popup_categories
  end
  
  def self.check_and_push(name:, is_empty:, cancelled_categories:, current_popup_categories:)
    current_popup_categories.push(name) if is_empty && cancelled_categories.exclude?(name)
  end
end
