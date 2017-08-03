class CorporateBaseController < AuthenticatedController
  before_action :redirect_unless_corporate
  before_action :corporate_activated?, except: [:index]
  before_action :set_corporate_contact_by_user_profile, only: [:edit, :show]
  before_action :set_corporate_user_by_user_profile, :set_corporate_profile, only: [:edit, :update]
  
  before_action :set_index_breadcrumbs, :only => %w(new edit show)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_new_crumbs, only: [:new]
  before_action :set_edit_crumbs, only: [:edit]
  
  include BreadcrumbsErrorModule
  include UserTrafficModule
  
  helper_method :invitation_sent?
  
  def index(account_type:)
    corporate_users_emails = CorporateAdminAccountUser.select { |x| x.corporate_admin == current_user && x.account_type == account_type }
                                                      .map(&:user_account).map(&:email).map(&:downcase)
    @corporate_contacts = Contact.for_user(current_user)
                                 .select { |c| (corporate_users_emails.include? c.emailaddress.downcase) && c.user_profile.present? }
    @corporate_profile =
      if current_user.corporate_admin
        CorporateAccountProfile.find_by(user: current_user)
      elsif current_user.corporate_employee?
        CorporateAccountProfile.find_by(user: current_user.corporate_admin_by_user)
      end
  end
  
  def create(account_type:, success_return_path:)
    respond_to do |format|
      if @user_account.save
        CorporateAdminAccountUser.create(corporate_admin: current_user, user_account: @user_account,
                                         account_type: CorporateAdminAccountUser.account_types[account_type])
        create_associated_contact
        corporate_admin_contact = create_corporate_admin_contact_for_user_account
        CorporateAdminService.add_category_share_for_corporate_admin(current_user, corporate_admin_contact, @user_account)
        format.html { redirect_to success_path(success_return_path), flash: { success: "#{account_type} Account successfully created." } }
        format.json { render :show, status: :created, location: @user_account }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update(account_type:, success_return_path:, params_to_update:)
    respond_to do |format|
      if @user_account.update(params_to_update)
        corporate_profile = Contact.for_user(current_user).find_by(emailaddress: @user_account.email).user_profile
        update_associated_contacts
        format.html { redirect_to success_path(success_return_path), flash: { success: "#{account_type} Account successfully updated." } }
        format.json { render :show, status: :created, location: @user_account }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @user_accounts.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def send_invitation
    corporate_contact = corporate_contact_by_contact_id(params[:contact_id])
    corporate_profile = corporate_contact.try(:user_profile)
    corporate_type = corporate_profile.user.corporate_type
    respond_to do |format|
      if ShareInvitationService.send_corporate_invitation(corporate_contact, current_user)
        format.html { redirect_to details_path(corporate_type, corporate_profile), flash: { success: 'Invitation has been successfully sent.' } }
      else
        format.html { redirect_to details_path(corporate_type, corporate_profile), flash: { error: 'Error sending an invitation, please try again later.' } }
      end
    end
  end
  
  def invitation_sent?(contact)
    account_user = User.find_by(email: contact.emailaddress)
    corporate_admin_record = CorporateAdminAccountUser.find_by(corporate_admin_id: current_user.id, user_account_id: account_user.id)
    return nil unless corporate_admin_record.present?
    corporate_admin_record.confirmation_sent_at.present?
  end
  
  private
  
  def redirect_if_corporate_employee
    redirect_to root_path if current_user.present? && current_user.corporate_employee?
  end
  
  def redirect_unless_corporate
    redirect_to root_path unless current_user.present? && (current_user.corporate_admin || current_user.corporate_employee?)
  end
  
  def corporate_activated?
    return true if current_user.present? && current_user.corporate_employee?
    redirect_to corporate_accounts_path unless current_user.present? && current_user.corporate_admin &&
                                               current_user.corporate_activated
  end
  
  def details_path(account_type, corporate_profile)
    case account_type
      when CorporateAdminAccountUser.employee_type
        corporate_employee_path(corporate_profile)
      when CorporateAdminAccountUser.client_type
        corporate_account_path(corporate_profile)
    end
  end
  
  def create_corporate_admin_contact_for_user_account
    account_profile = CorporateAccountProfile.find_by(user: current_user)
    Contact.create(user_id: @user_account.id,
                   businessname: account_profile.try(:business_name),
                   businesswebaddress: account_profile.try(:web_address),
                   business_street_address_1: account_profile.try(:street_address),
                   city: account_profile.try(:city),
                   state: account_profile.try(:state),
                   zipcode: account_profile.try(:zip),
                   businessphone: account_profile.try(:phone_number),
                   businessfax: account_profile.try(:fax_number),
                   photourl: current_user.user_profile.photourl,
                   emailaddress: current_user.email,
                   firstname: current_user.first_name,
                   lastname: current_user.last_name,
                   contact_type: account_profile.try(:contact_type),
                   relationship: account_profile.try(:relationship),
                   corporate_contact: true
    )
  end
  
  def create_associated_contact
    admin_contact = Contact.find_or_initialize_by(emailaddress: @user_account.email,
                                                  user_id: current_user.id)
    admin_contact.update(user_profile: @user_account.user_profile)
    admin_contact.save
    user_profile = admin_contact.user_profile
    update_contact_attributes(admin_contact, user_profile)
  end
  
  def update_associated_contacts
    admin_contact = Contact.where(emailaddress: @user_account.email, user_id: current_user.id).first
    user_profile = admin_contact.user_profile
    update_contact_attributes(admin_contact, user_profile)
  end
  
  def update_contact_attributes(contact, user_profile)
    contact.update_attributes(
      firstname: user_profile.first_name,
      lastname: user_profile.last_name,
      phone: user_profile.two_factor_phone_number,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      birthdate: user_profile.date_of_birth,
      address: [user_profile.street_address_1, user_profile.street_address_2].compact.join(" "),
      zipcode: user_profile.zip,
      state: user_profile.state,
      city: user_profile.city
    )
  end
  
  def set_corporate_contact_by_user_profile
    user_profile = UserProfile.find_by(id: params[:id])
    return unless user_profile.present?
    return unless user_accounts.include? user_profile.user
    @corporate_contact = Contact.where(user_profile_id: user_profile.id, user_id: current_user.id).first
  end
  
  def set_corporate_user_by_user_profile
    return unless current_user.corporate_admin
    user_id = UserProfile.find_by(id: params[:id]).user_id
    user = User.find_by(id: user_id)
    return unless user_accounts.include? user
    @user_account = user
  end
  
  def set_corporate_profile
    @corporate_profile = Contact.for_user(current_user).find_by(emailaddress: @user_account.email).user_profile
  end
  
  def corporate_contact_by_contact_id(contact_id)
    return nil unless contact_id.present? &&
           (corporate_contact = Contact.find_by(id: contact_id)).present?
    corporate_contact
  end
end
