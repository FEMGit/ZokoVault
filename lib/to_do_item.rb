class ToDoItem
  extend CategoriesHelper
  class << self
    include Rails.application.routes.url_helpers
    ActionView::Helpers
  end

  BASE = 'to_do_popup_modals/'
  TO_DO_ITEMS = {
    Rails.application.config.x.ProfileCategory => { 
      name: BASE + 'my_profile_modal',
      setup_path: edit_user_profile_path,
      image_path: 'setup_modal/my_profile.jpg',
      description: "Complete your personal profile, including your address and employment information.",
      title: "Personal Profile"},
    "Vault Co-Owner" => { 
      name: BASE + 'vault_co_owner_modal',
      setup_path: vault_co_owners_account_settings_path,
      image_path: 'setup_modal/vault_co_owner.jpg',
      description: "You can allow a third-party 100% access to your Vault. This is typically provided to a spouse, executor, or family member.",
      title: "Co-Owner"},
    "Vault Inheritance" => { 
      name: BASE + 'vault_inheritance_modal',
      setup_path: vault_inheritance_account_settings_path,
      image_path: 'setup_modal/vault_inheritance.jpg',
      description: "Set up a chain of custody for your vault by designating a Contingent Owner. This is typically provided to the executor of your estate.",
      title: "Vault Inheritance"},
=begin
    Rails.application.config.x.OnlineAccountCategory => { 
      name: BASE + 'online_accounts_modal',
      setup_path: online_accounts_path,
      image_path: 'setup_modal/online_accounts.jpg',
      description: "Store your login and password information for social media, utility companies, banks and more.",
      title: "Online Accounts"},
=end
    Rails.application.config.x.FinancialInformationCategory => { 
      name: BASE + 'financial_information_modal',
      setup_path: financial_information_path,
      image_path: 'setup_modal/financial_information.png',
      description: "Document your property, investments, bank accounts, financial advisors and debp for your family.",
      title: "Financial Information"},
    Rails.application.config.x.WillsPoaCategory => { 
      name: BASE + 'wills_and_powers_of_attorney_modal',
      setup_path: wills_powers_of_attorney_path,
      image_path: 'setup_modal/wills_and_powers_of_attorney.jpg',
      description: "Store digital records of your Wills, Living Wills and Powers of Attorney for your family.",
      title: "Wills & Powers of Attorney"},
    Rails.application.config.x.TrustsEntitiesCategory => { 
      name: BASE + 'trusts_and_entities_modal',
      setup_path: trusts_entities_path,
      image_path: 'setup_modal/trusts_and_entities.jpg',
      description: "Store details regarding your family trusts, charities and private entities.",
      title: "Trusts & Entities"},
    Rails.application.config.x.InsuranceCategory => { 
      name: BASE + 'insurance_modal',
      setup_path: insurance_path,
      image_path: 'setup_modal/insurance.jpg',
      description: "Store information regarding your health, property, life and disability insurance.",
      title: "Insurance"},
    Rails.application.config.x.TaxCategory => { 
      name: BASE + 'taxes_modal',
      setup_path: taxes_path,
      image_path: 'setup_modal/taxes.jpg',
      description: "Store your tax records and documents.",
      title: "Taxes"},
    Rails.application.config.x.FinalWishesCategory => { 
      name: BASE + 'final_wishes_modal',
      setup_path: final_wishes_path,
      image_path: 'setup_modal/final_wishes.jpg',
      description: "Record your plans for pet care, burial, charity, organ donation and more.",
      title: "Final Wishes"}
  }

  def self.random_item(user:)
    return nil unless user && user.login_count && user.login_count > 1
    return nil if user.free? || user.corporate_manager? || user.corporate_user?
    categories = to_do_categories(user: user)
    return nil unless (random_modal = TO_DO_ITEMS.select { |key, value| categories.include? key }.values.sample)
    random_modal
  end

  def self.category_name_by_modal_route(path:)
    TO_DO_ITEMS.invert.select { |cp| cp[:name].include? path.remove(BASE) }.values.first
  end
  
  def self.all_items(user:)
    TO_DO_ITEMS.select { |cat, _params| to_do_categories(user: user).include? cat }.map { |k, v| [k => v] }.flatten
  end

  private
  
  def self.to_do_categories(user:)
    cancelled_categories = ToDoCancel.find_or_initialize_by(user: user).cancelled_categories
    to_do_categories = []
    check_and_push(name: 'Vault Inheritance', is_empty: vault_inheritance_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: 'Vault Co-Owner', is_empty: vault_co_owner_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    # check_and_push(name: Rails.application.config.x.OnlineAccountCategory, is_empty: online_accounts_empty?(user),
    #                cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.FinalWishesCategory, is_empty: final_wishes_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.FinancialInformationCategory, is_empty: financial_information_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.WillsPoaCategory, is_empty: wills_poa_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.TrustsEntitiesCategory, is_empty: trusts_entities_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.InsuranceCategory, is_empty: insurance_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.TaxCategory, is_empty: taxes_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    check_and_push(name: Rails.application.config.x.ProfileCategory, is_empty: my_profile_empty?(user),
                   cancelled_categories: cancelled_categories, current_to_do_categories: to_do_categories)
    to_do_categories
  end

  def self.check_and_push(name:, is_empty:, cancelled_categories:, current_to_do_categories:)
    current_to_do_categories.push(name) if is_empty && cancelled_categories.exclude?(name)
  end
end
