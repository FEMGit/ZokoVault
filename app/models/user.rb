class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include StagingHelper
  attr_accessor :skip_password_validation, :confirm_email

  devise :database_authenticatable, :confirmable, :lockable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable,
         :password_archivable

  # == Scope methods
  scope :online, -> { where("updated_at > ?", Rails.application.config.x.UserOnlineRange.ago) }

  # == Validations
  validates :email, :email_format => { :message => "Email should contain @ and domain like .com" }
  validate :email_is_valid?
  validates_confirmation_of :email, message: "Emails do not match", if: :confirm_email?
  validates_presence_of :email_confirmation, message: 'Required', if: :confirm_email?

  validate :password_complexity

  # == Associations
  has_many :vendors, dependent: :nullify
  has_many :shares, dependent: :destroy
  has_many :user_activities, dependent: :destroy
  has_many :user_death_traps, dependent: :destroy
  has_many :tax_year_infos, dependent: :destroy
  has_many :final_wish_infos, dependent: :destroy
  has_many :financial_investments, dependent: :destroy
  has_many :financial_alternatives, dependent: :destroy
  has_many :financial_properties, dependent: :destroy
  has_many :financial_account_informations, dependent: :destroy
  has_many :power_of_attorneys, dependent: :destroy
  has_many :power_of_attorney_contacts, dependent: :destroy
  has_many :entities, dependent: :destroy
  has_many :card_documents, dependent: :destroy
  has_many :user_traffics, dependent: :destroy
  has_many :payments
  has_one :tutorial_selection, dependent: :destroy
  has_many :categories, class_name: 'CorporateAdminCategory', dependent: :destroy
  has_one :corporate_account_profile, dependent: :destroy


  has_one  :stripe_subscription, -> { order("created_at DESC") }
  accepts_nested_attributes_for :stripe_subscription

  has_one  :stripe_customer_record, class_name: "StripeCustomer", inverse_of: :user

  has_one :user_profile, -> { order("created_at DESC") }, dependent: :destroy

  accepts_nested_attributes_for :user_profile, update_only: true

  has_many :user_subscriptions, dependent: :destroy
  has_one :current_user_subscription_marker, dependent: :destroy
  has_one :current_user_subscription,
    through: :current_user_subscription_marker, source: :user_subscription

  has_one :corporate_provider_join, class_name: 'CorporateAdminAccountUser',
            foreign_key: :user_account_id, inverse_of: :user_account
  has_many :corporate_client_joins, class_name: 'CorporateAdminAccountUser',
            foreign_key: :corporate_admin_id, inverse_of: :corporate_admin

  # == Delegations
  delegate :mfa_frequency, :initials, :first_name, :middle_name, :last_name,
           :name, :phone_number, :phone_number_mobile, :two_factor_phone_number,
           :date_of_birth, :signed_terms_of_service?, :street_address_1,
           :city, :state, :zip, to: :user_profile, allow_nil: true

  def category_shares
    @category_shares ||= shares.categories
  end

  def primary_shared_with?(shared_user)
    return false unless shared_user.present?
    shared_user.user_profile
               .primary_shared_with
               .map { |sh| sh.emailaddress.downcase }
               .include? email.downcase
  end

  def primary_shared_with_by_contact?(contact)
    return false unless contact.present?
    user_profile.primary_shared_with
                .map { |sh| sh.emailaddress.downcase }
                .include? contact.emailaddress.downcase
  end

  def primary_shared_with_or_owner?(shared_user)
    return false unless shared_user.present?
    return true if shared_user == self
    self.primary_shared_with?(shared_user)
  end

  def stripe_customer
    stripe_customer_record.try(:fetch)
  end

  def free?
    !paid? && !primary_shared_of_paid?
  end

  def corporate_categories
    return [] unless categories.present?
    Category.all.select { |c| categories.map(&:category_id).include? c.id }
  end

  def corporate_users
    return [] unless corporate_admin
    CorporateAdminAccountUser.select { |ca| ca.corporate_admin == self }.map(&:user_account)
  end

  def employee_users
    return [] unless corporate_employee?
    CorporateEmployeeAccountUser.select { |ce| ce.corporate_employee == self }.map(&:user_account).compact
  end

  def employee_contact_type
    CorporateEmployeeProfile.find_by(corporate_employee: self).try(:contact_type)
  end

  def employee_relationship
    CorporateEmployeeProfile.find_by(corporate_employee: self).try(:relationship)
  end

  def corporate_manager?
    corporate_employee? || corporate_admin
  end

  def corporate_user?
    corporate_provider_join.present? &&
    corporate_provider_join.corporate_admin.present?
  end

  def corporate_client?
    corporate_user? && corporate_provider_join.client?
  end

  def corporate_employee?
    corporate_user? && corporate_provider_join.employee?
  end

  def corporate_account_owner
    corporate_provider_join.corporate_admin if corporate_user?
  end

  def corporate_type
    corporate_account_record = CorporateAdminAccountUser.find_by(user_account_id: id)
    CorporateAdminAccountUser.find_by(user_account_id: id).try(:account_type)
  end

  def logged_in_at_least_once?
    last_sign_in_at.present?
  end

  def corporate_user_by_admin?(admin)
    CorporateAdminAccountUser.find_by(corporate_admin_id: admin.try(:id), user_account_id: id).present?
  end

  def corporate_admin_by_user
    CorporateAdminAccountUser.find_by(user_account_id: id).try(:corporate_admin)
  end

  def corporate_user_by_employee?(employee)
    CorporateEmployeeAccountUser.find_by(corporate_employee_id: employee.try(:id), user_account_id: id).present?
  end
  
  def corporate_user_by_manager?(manager)
    corporate_user_by_employee?(manager) || corporate_user_by_admin?(manager)
  end

  def corporate_employees_by_user
    CorporateEmployeeAccountUser.where(user_account_id: id).map(&:corporate_employee)
  end

  def corporate_invitation_sent?
    corporate_record = CorporateAdminAccountUser.find_by(user_account_id: id)
    corporate_record.present? && corporate_record.confirmation_sent_at.present?
  end

  def primary_shared_of_paid?
    # TODO: after migrating data for PrimarySharedUser, switch to:
    # persisted? && PrimarySharedUser.where(shared_with_user_id: id)
    #                                .map(&:owning_user).any?(&:paid?)
    UserProfile
      .includes(:user)
      .where(id: Contact.where(emailaddress: email).map(&:full_primary_shared_id))
      .map(&:user)
      .any?(&:paid?)
  end

  def paid?
    current_user_subscription.present? && current_user_subscription.active?
  end

  def primary_shared_with?(shared_user)
    return false unless shared_user.present?
    shared_user.user_profile
               .primary_shared_with
               .map { |sh| sh.emailaddress.downcase }
               .include? email.downcase
  end

  def primary_shared_with_or_owner?(shared_user)
    return false unless shared_user.present?
    return true if shared_user == self
    self.primary_shared_with?(shared_user)
  end

  def mfa_verify?
    case mfa_frequency
    when "never"
      false
    when "always"
      true
    else
      current_sign_in_ip != last_sign_in_ip
    end
  end

  def after_database_authentication
    date = Date.current
    if UserActivity.for_date(date).for_user(self).any?
      u_activity = UserActivity.for_date(date).for_user(self).first
      u_activity.update(user: self, login_count: u_activity.login_count + 1)
    else
      UserActivity.create(user: self, login_date: date, login_count: 1, session_length: 0)
    end
  end

  def password_complexity
    return unless password.present?
    if !satisfy_password_requirement?(password)
      errors.add :password, "Must include uppercase letters, lowercase letters, numbers and characters"
    elsif include_personal_data?
      errors.add :password, "Avoid using your personal information: name, username, company name"
    end
  end

  def satisfy_password_requirement?(password)
    required_conditions_number_to_pass = 4
    lowercase = password.match(/^(?=.*[a-z])/)
    uppercase = password.match(/^(?=.*[A-Z])/)
    number = password.match(/^(?=.*\d)/)
    characters = password.match(/^(?=.*[&!',:\\;"\\.*@#\\$%\\^()_])/)
    match_length(lowercase) + match_length(uppercase) + match_length(number) + match_length(characters) >= required_conditions_number_to_pass
  end

  def match_length(match)
    return 0 unless match.present?
    match.length
  end

  def include_personal_data?
    email_nick = email.split("@").first
    date_of_birth_year = date_of_birth && date_of_birth.year.to_s || ""
    [date_of_birth_year, email_nick, first_name, last_name, middle_name].any? { |x| x.present? && password.downcase.include?(x.downcase) }
  end

  def skip_password_validation!
    @skip_password_validation = true
  end

  def confirm_email!
    @confirm_email = true
  end

  before_create { set_as_admin }
  before_destroy :corporate_contacts_clear, :clear_user_traffics_shared_user
  after_destroy :invitation_sent_clear, :corporate_admin_accounts_clear,
                                        :corporate_employees_clear

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  def confirm_email?
    @confirm_email == true
  end

  private

  def email_is_valid?
    MailService.email_is_valid?(email, errors, :email)
  end

  # XXX: We do not have "roles" established. I am using a weak association to
  # establish an admin. If the user has a zokuvault.com email address. Please
  # note that this is not secure at all. It is very dangerous. Proper roles
  # should be established quickly.

  ADMIN_REGEX = /@zokuvault.com$/
  def set_as_admin
    self.admin ||= (email =~ ADMIN_REGEX).present?
    true
  end

  def invitation_sent_clear
    ShareInvitationSent.where("contact_email ILIKE ?", email).destroy_all
  end

  def corporate_employees_clear
    CorporateEmployeeAccountUser.where(user_account_id: id).delete_all
    CorporateEmployeeAccountUser.where(corporate_employee_id: id).delete_all
    CorporateEmployeeProfile.where(corporate_employee_id: id).delete_all
  end

  def corporate_admin_accounts_clear
    CorporateAdminAccountUser.where(user_account_id: id).delete_all
    CorporateAdminAccountUser.where(corporate_admin_id: id).delete_all
  end

  def corporate_contacts_clear
    Contact.where(emailaddress: email, relationship: 'Account Owner').destroy_all
  end

  def clear_user_traffics_shared_user
    UserTraffic.where(shared_user_id: id).destroy_all
  end
end
