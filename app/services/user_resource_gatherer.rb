#
# This service class uses a naive approach to stage all shared information for a
# user
#
# UserResourceGatherer.new(user).all_resources
# return Array[<shareable resource>]
#
class UserResourceGatherer < Struct.new(:user)
  include ContactsHelper
  attr_reader :user

  def initialize(user)
    @user = user
  end
  
  def categories
    return CategoryLinks::LINKS unless user.corporate_manager?
  end
  
  def shared_categories
    shared_category_links = []
    SharedViewService.category_shares(shares).each do |shared_category|
      shared_category_links.push({ name: shared_category.shareable.name, 
                                   path: CategoryLinks.shared_view_category_link(category_name: shared_category.shareable.name,
                                                                                 shared_user_id: shared_category.user_id)})
    end
    shared_category_links
  end

  def regular_user_resources
    return @my_resources if @my_resources

    @my_resources =
      categories |
      gather_wills_poa(user, Category.fetch('wills - poa')) |
      gather_trusts_entities(user, Category.fetch('trusts & entities')) |
      gather_insurance(user, Category.fetch('insurance')) |
      gather_contacts(user) |
      gather_taxes(user, Category.fetch('taxes')) |
      gather_documents(user) |
      gather_final_wishes(user, Category.fetch('final wishes')) |
      gather_financial_information(user, Category.fetch('financial information'))
    
    @my_resources.flatten!
    @my_resources
  end
  
  def corporate_admin_resources
    gather_contacts(user) |
      gather_corporate_account_settings(user) |
      gather_corporate_clients(user) |
      gather_corporate_employees(user)
  end
  
  def corporate_employee_resources
    gather_contacts(user) |
      gather_corporate_clients(user)
  end

  def shared_resources
    @shared_resources = Share
      .where(contact: Contact.where("emailaddress ILIKE ?", user.email))
      .select(&:shareable_type)
        .map do |share|
          if Category === share.shareable
            category_resources(share)
          else
            share.shareable
          end
        end
    @shared_resources.flatten!
    @shared_resources | shared_categories
  end
  
  def shares
    @shared_resources = Share.where(contact: Contact.where("emailaddress ILIKE ?", user.email))
                             .select(&:shareable_type)
                             .flatten
  end
  
  def my_resources
    if user.corporate_admin?
      corporate_admin_resources
    elsif user.corporate_employee?
      corporate_employee_resources
    else
      regular_user_resources
    end
  end

  def all_resources
    my_resources | shared_resources
  end

  def category_resources(share)
    user, category = share.user, share.shareable

    case category
    when Category.fetch('wills - poa')
      gather_wills_poa(user, category)
    when Category.fetch('trusts & entities')
      gather_trusts_entities(user, category)
    when Category.fetch('insurance');
      gather_insurance(user, category)
    # when Category.fetch('contact')
    #   Contact.for_user(user)
    when Category.fetch('taxes')
      gather_taxes(user, category)
    when Category.fetch('final wishes')
      gather_final_wishes(user, category)
    when Category.fetch('financial information')
      gather_financial_information(user, category)
    end
  end
  
  private
  
  def gather_wills_poa(user, category)
    Will.for_user(user) |
    PowerOfAttorneyContact.for_user(user) |
    Document.for_user(user).where(category: category.name)
  end
  
  def gather_trusts_entities(user, category)
    Trust.for_user(user) |
    Entity.for_user(user) |
    Document.for_user(user).where(category: category.name)
  end

  def gather_insurance(user, category)
    Vendor.for_user(user).where(category: category) |
    Document.for_user(user).where(category: category.name)
  end

  def gather_taxes(user, category)
    TaxYearInfo.for_user(user) |
      Tax.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end

  def gather_final_wishes(user, category)
    FinalWishInfo.for_user(user) |
      FinalWish.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end

  def gather_financial_information(user, category)
    FinancialInvestment.for_user(user) |
      FinancialProperty.for_user(user) |
      FinancialProvider.for_user(user) |
      Document.for_user(user).where(category: category.name)
  end
  
  def gather_contacts(user)
    return Contact.for_user(user) unless user.corporate_manager?
    Contact.for_user(user).where("emailaddress ILIKE ?", user.email.downcase)
  end
  
  def gather_documents(user)
    Document.for_user(user)
  end
  
  def gather_corprote_accounts(user)
    CorporateAccount.for_user(user)
  end
  
  # Corporate User
  
  def gather_corporate_account_settings(user)
    return [] unless user.corporate_admin?
    CorporateAccountProfile.for_user(user)
  end
  
  def gather_corporate_clients(user)
    return [] unless user.corporate_manager?
    corporate_client_emails = (user.employee_users + user.corporate_users).select(&:corporate_client?).map(&:email)
    Contact.for_user(user.corporate_account_owner).where(emailaddress: corporate_client_emails)
                                                  .map { |contact| CorporateClient.new({ name: contact.user_profile.name,
                                                                                         email: contact.emailaddress,
                                                                                         phone_number: contact.user_profile.phone_number,
                                                                                         mobile_phone_number: contact.user_profile.two_factor_phone_number,
                                                                                         date_of_birth: contact.user_profile.date_of_birth,
                                                                                         street: contact.user_profile.street_address_1,
                                                                                         city:  contact.user_profile.city,
                                                                                         state:  contact.user_profile.state,
                                                                                         zip:  contact.user_profile.zip,
                                                                                         has_logged_in: associated_user_logged_in?(contact),
                                                                                         managed_by: managed_by_contacts(contact).map(&:name)}) }
  end
  
  def gather_corporate_employees(user)
    return [] unless user.corporate_admin?
    corporate_employee_emails = (user.employee_users + user.corporate_users).select(&:corporate_employee?).map(&:email)
    Contact.for_user(user).where(emailaddress: corporate_employee_emails).map { |contact| CorporateEmployee.new(
                                                                                        { name: contact.user_profile.name,
                                                                                          email: contact.emailaddress,
                                                                                          mobile_phone_number: contact.user_profile.two_factor_phone_number,
                                                                                          managed_users: User.where("email ILIKE ?", contact.emailaddress.downcase).first.corporate_employees_by_user.map(&:name)}) }
  end
end