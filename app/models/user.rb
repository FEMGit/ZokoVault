class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable,
         :password_archivable

  # == Scope methods
  scope :online, -> { where("updated_at > ?", Rails.application.config.x.UserOnlineRange.ago) }

  # == Validations
  validates_format_of :email,
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                      :message => "Email should contain @ and domain like '.com'"

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
  has_many :uploads, dependent: :destroy
  has_many :user_traffics, dependent: :destroy
  has_many :payments
  has_one :subscription, -> { order("created_at DESC") }
  accepts_nested_attributes_for :subscription

  has_one :user_profile, -> { order("created_at DESC") }, dependent: :destroy

  accepts_nested_attributes_for :user_profile, update_only: true

  has_many :user_subscriptions, dependent: :destroy
  has_one :current_user_subscription_marker, dependent: :destroy
  has_one :current_user_subscription,
    through: :current_user_subscription_marker, source: :user_subscription

  # == Delegations
  delegate :mfa_frequency, :initials, :first_name, :middle_name, :last_name,
           :name, :phone_number, :phone_number_mobile, :two_factor_phone_number,
           :date_of_birth, :signed_terms_of_service?, to: :user_profile, allow_nil: true

  # == Callbacks
  after_create :add_subscriber_to_list

  def category_shares
    @category_shares ||= shares.categories
  end

  def free?
    !paid? && !primary_shared_of_paid?
  end

  def primary_shared_of_paid?
    # TODO: after migrating data for PrimarySharedUser, switch to:
    # persisted? && PrimarySharedUser.where(shared_with_user_id: id)
    #                                .map(&:owning_user).any?(&:paid?)
    UserProfile
      .includes(:user)
      .where(id: Contact.where(emailaddress: email)
      .map(&:full_primary_shared_id))
      .map(&:user)
      .any?(&:paid?)
  end

  def paid?
    current_user_subscription.present? && current_user_subscription.active?
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
    lowercase = password.match(/^(?=.*[a-z])/)
    uppercase = password.match(/^(?=.*[A-Z])/)
    number = password.match(/^(?=.*\d)/)
    characters = password.match(/^(?=.*[&!',:\\;"\\.*@#\\$%\\^()_])/)
    match_length(lowercase) + match_length(uppercase) + match_length(number) + match_length(characters) >= 3
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

  before_create { set_as_admin }
  after_destroy :invitation_sent_clear

  private

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

  # Subscribe a member to a list:
  def add_subscriber_to_list
    api_key = ZokuVault::Application.config.mailchimp_secret_token
    gibbon = Gibbon::Request.new(api_key: api_key, debug: true, logger: nil)

    gibbon.lists(ZokuVault::Application.config.mailchimp_listing_id).members.create(
      body: {
        email_address: self.email,
        status: "subscribed",
        merge_fields: {
          FNAME: self.first_name,
          LNAME: self.last_name
        }
      }
    )
  end
end
