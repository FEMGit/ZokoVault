module ApplicationHelper
  def us_states
    States::STATES
  end
  
  def months
    Months::MONTHS
  end
  
  def card_expiration_years
    Years::CARD_EXPIRATION_YEARS
  end

  def initialize_new_contact_form
    return if content_for?(:new_contact_form)
    @contact = Contact.new
    content_for :new_contact_form, render("contacts/ajax_form")
  end
  
  def account_owner_select_with_create_new(form, name, account_owners, html_options = {}, selected_items = [])
    initialize_new_contact_form
    select_options = account_owners.dup
    select_options.prepend([ "create_new_contact", "Create New Contact", class: "create-new"]).prepend([])

    local_options = {
      'data-placeholder': 'Choose Contacts...',
      class: 'chosen-select add-new-contactable account-owner',
      multiple: true,
      onchange: "handleSelectOnChange(this);",
      disabled: disabled?(name)
    }.merge(html_options)

    form.collection_select(name, select_options,
                           :first, :second, {selected: selected_items}, local_options)
  end

  def contact_select_with_create_new(form, name, contacts, html_options = {}, selected_items = [], include_create_new_contact = true)
    initialize_new_contact_form
    select_options = contacts ? contacts.sort_by { |s| s.lastname.downcase }.collect { |s| [s.id, s.name, class: "contact-item"] } : []
    if include_create_new_contact
      select_options.prepend([ "create_new_contact", "Create New Contact", class: "create-new"]).prepend([])
    else
      select_options.prepend([ "create_new_contact", "", class: "create-new d-none", disabled: 'disabled']).prepend([])
    end

    contacts_placeholder_text = 
      if html_options[:multiple].eql?(false)
        'Choose Contact...'
      else
        'Choose Contacts...'
      end
    
    local_options = {
      'data-placeholder': contacts_placeholder_text,
      class: 'chosen-select add-new-contactable',
      multiple: true,
      onchange: "handleSelectOnChange(this);",
      disabled: disabled?(name)
    }.merge(html_options)

    if selected_items.present?
      form.collection_select(name, select_options,
                             :first, :second, {selected: selected_items}, local_options)
    else
      form.collection_select(name, select_options,
                             :first, :second, {}, local_options)
    end
  end

  def category_view_path(category, user = nil)
    case category.try(:name)
    when Rails.application.config.x.WillsPoaCategory
      return wills_powers_of_attorney_shared_view_path(user) if @shared_user.present?
      wills_powers_of_attorney_path
    when Rails.application.config.x.TrustsEntitiesCategory
      return trusts_entities_shared_view_path(user) if @shared_user.present?
      trusts_entities_path
    when Rails.application.config.x.InsuranceCategory
      return insurance_shared_view_path(user) if @shared_user.present?
      insurance_path
    when Rails.application.config.x.TaxCategory
      return taxes_shared_view_path(user) if @shared_user.present?
      taxes_path
    when Rails.application.config.x.FinalWishesCategory
      return final_wishes_shared_view_path(user) if @shared_user.present?
      final_wishes_path
    when Rails.application.config.x.OnlineAccountCategory
      return online_accounts_shared_view_path(user) if @shared_user.present?
      online_accounts_path
    when Rails.application.config.x.FinancialInformationCategory
      return financial_information_shared_view_path(user) if @shared_user.present?
      financial_information_path
    when Rails.application.config.x.DocumentsCategory
      return documents_shared_view_path(user) if @shared_user.present?
      documents_path
    when Rails.application.config.x.ContactCategory
      return contacts_shared_view_path(user) if @shared_user.present?
      contacts_path
    else
      return dashboard_shared_view_path(user) if @shared_user.present?
    end
  end
  
  def subcategory_name(subcategory)
    title = 
      if subcategory.is_a? Tax
        tax_year = TaxYearInfo.find(subcategory.tax_year_id)
        tax_year.year.to_s
      elsif subcategory.is_a? TaxYearInfo
        subcategory.year.to_s
      elsif subcategory.is_a? FinalWishInfo
        subcategory.group
      elsif subcategory.is_a? FinalWish
        final_wish_info = FinalWishInfo.find(subcategory.final_wish_info_id)
        final_wish_info.group
      else
        subcategory.try(:title) || subcategory.try(:name) || subcategory.class.name.titleize
      end
    return title unless subcategory.present? && subcategory.try(:category)
    "#{subcategory.category.name} - #{title}"
  end
  
  def subcategory_view_path(subcategory)
    set_shared_user(subcategory)
    case subcategory
      when Will
        return will_path(subcategory, @shared_user) if 
        will_path(subcategory)
      when Trust
        return trust_path(subcategory, @shared_user) if @shared_user.present?
        trust_path(subcategory)
      when Entity
        return entity_path(subcategory, @shared_user) if @shared_user.present?
        entity_path(subcategory)
      when PowerOfAttorneyContact
        return power_of_attorney_path(subcategory, @shared_user) if @shared_user.present?
        power_of_attorney_path(subcategory)
      when PropertyAndCasualty
        return property_and_casualty_shared_view_path(@shared_user, subcategory) if @shared_user.present?
        property_path(subcategory)
      when LifeAndDisability
        return life_and_disability_shared_view_path(@shared_user, subcategory) if @shared_user.present?
        life_path(subcategory)
      when Health
        return health_shared_view_path(@shared_user, subcategory) if @shared_user.present?
        health_path(subcategory)
      when Tax
        tax_year = TaxYearInfo.find(subcategory.tax_year_id)
        return tax_shared_view_path(@shared_user, tax_year) if @shared_user.present?
        tax_path(tax_year)
      when TaxYearInfo
        return tax_shared_view_path(@shared_user, subcategory) if @shared_user.present?
        tax_path(subcategory)
      when FinalWish
        final_wish_info = FinalWishInfo.find(subcategory.final_wish_info_id)
        return final_wish_shared_view_path(@shared_user, final_wish_info) if @shared_user.present?
        final_wish_path(final_wish_info)
      when FinalWishInfo
        return final_wish_shared_view_path(@shared_user, subcategory) if @shared_user.present?
        final_wish_path(subcategory)
      when FinancialProvider
        path_to_resource(subcategory)
      when Document
        return shared_document_path(@shared_user, subcategory) if @shared_user.present?
        document_path(subcategory)
      when CorporateAccountProfile
        corporate_account_settings_path
      when CorporateClient,
           CorporateEmployee
        corporate_user_profile = Contact.for_user(current_user.corporate_account_owner).where("emailaddress ILIKE ?", subcategory.email).first.user_profile
        return corporate_employee_path(corporate_user_profile) if corporate_user_profile.user.corporate_employee?
        corporate_account_path(corporate_user_profile)
      else
        ""
      end
  end
  
  def disabled?(name)
    @shared_user.present? && (shared_with_property_names.include? name.to_s)
  end
  
  def edit?(object)
    object.id.present?
  end
  
  def shared_with_property_names
    %w(share_with_contact_ids contact_ids share_with_ids)
  end
  
  private
  
  def set_shared_user(subcategory)
    shares_for_current_user = Share.where(contact: Contact.where("emailaddress ILIKE ?", current_user.email))
    if @shared_user.blank? && (subcategory.try(:user) && subcategory.user != current_user) &&
        shares_for_current_user.find_by(user: subcategory.user).present?
      @shared_user = subcategory.user
    end
  end
end
