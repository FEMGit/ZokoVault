class CorporateAccountsController < CorporateBaseController
  before_action :redirect_if_corporate_employee, only: [:account_settings, :edit_account_settings, :update_account_settings,
                                                        :billing_information]
  before_action :set_account_settings_crumbs, only: [:account_settings, :edit_account_settings]
  before_action :set_edit_corporate_details_crumbs, only: [:edit_account_settings]

  include SharedUserExpired

  def set_index_breadcrumbs
    add_breadcrumb "Corporate Account", corporate_accounts_path
  end

  def set_new_crumbs
    add_breadcrumb "Add Client User", new_corporate_account_path
  end

  def set_details_crumbs
    add_breadcrumb "#{@corporate_contact.try(:name)} Details", corporate_account_path(@corporate_contact.user_profile_id)
  end

  def set_edit_crumbs
    add_breadcrumb "Edit Client User", edit_corporate_account_path(@corporate_contact.user_profile_id)
  end

  def set_account_settings_crumbs
    add_breadcrumb "Corporate Account Settings", account_settings_corporate_accounts_path
  end

  def set_edit_corporate_details_crumbs
    add_breadcrumb "Edit Client User", edit_corporate_settings_corporate_accounts_path
  end

  def page_name
    case action_name
      when 'index'
        "Corporate Account - Client Accounts"
      when 'new'
        "Corporate Account - Add Client User"
      when 'edit'
        "Corporate Account - Edit Client User"
      when 'show'
        "Corporate Account - Client Details"
      when 'account_settings'
        "Corporate Account - Account Settings"
      when 'edit_account_settings'
        "Corporate Account - Edit Account Settings"
      when 'billing_information'
        "Billing Information"
    end
  end

  def index
    super(account_type: CorporateAdminAccountUser.client_type)
    corporate_users_emails = CorporateAdminAccountUser.select { |x| x.corporate_admin == corporate_owner }
                                                      .map(&:user_account).map(&:email).map(&:downcase)
    shares_by_user = policy_scope(Share).each { |s| authorize s }.group_by(&:user)
    ShareService.append_primary_shares(current_user, shares_by_user)
    @shares_by_user = (shares_by_user[:primary_shared_user] + shares_by_user.keys.select { |x| x.is_a? User }).uniq.reject { |sh| corporate_users_emails.include? sh.email.downcase }
  end

  def billing_information
    stripe_customer = StripeService.ensure_corporate_stripe_customer(user: current_user)
    @card = StripeService.customer_card(customer: stripe_customer)
    @invoices = StripeService.all_invoices(customer: stripe_customer)
    session[:ret_url] = billing_information_corporate_accounts_path
  end

  def account_settings
    @corporate_profile = CorporateAccountProfile.find_by(user: current_user)
  end

  def show
    authorize @corporate_contact
    stripe_customer = StripeService.ensure_corporate_stripe_customer(user: corporate_owner)
    corporate_admin_customer_id = CorporateAccountProfile.find_by(user: corporate_owner).try(:stripe_customer_id)
    corporate_subscription_ids = StripeSubscription.where(user: @user_account, customer_id: corporate_admin_customer_id).map(&:subscription_id)
    @invoices = stripe_customer.invoices.to_a.select { |inv| inv[:lines][:data].any? { |sub| corporate_subscription_ids.include? sub[:id] } }
  end

  def new
    @user_account = User.new(user_profile: UserProfile.new)
    @user_account.confirm_email!
    new_account_form_billing_checks
  end

  def edit_account_settings
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: current_user)
    @corporate_profile.save
  end

  def update_account_settings
    @corporate_profile = CorporateAccountProfile.find_by(id: params[:id])
    @corporate_profile.company_information_required!
    respond_to do |format|
      if @corporate_profile.update(corporate_settings_params)
        format.html { redirect_to success_path(account_settings_corporate_accounts_path), flash: { success: 'Corporate Settings successfully updated.' } }
        format.json { render :index, status: :created, location: @corporate_profile }
      else
        error_path(:edit_account_settings)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout], locals: @path[:locals] }
        format.json { render json: @corporate_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @corporate_contact
  end

  def create
    @user_account = User.new(user_account_params)
    @user_account.skip_password_validation!
    @user_account.skip_confirmation!
    super(account_type: CorporateAdminAccountUser.client_type, success_return_path: corporate_accounts_path)
  end

  def update
    @corporate_contact = Contact.where(user_profile_id: @corporate_profile.id, user_id: corporate_owner.id).first
    authorize @corporate_contact
    super(account_type: CorporateAdminAccountUser.client_type, success_return_path: corporate_account_path(@corporate_profile) || corporate_accounts_path,
          params_to_update: user_account_params.except(:email))
  end

  def managed_by_contacts(contact)
    contact_user = User.where("email ILIKE ?", contact.emailaddress).first
    return nil unless contact_user.present?
    manager_emails = (Array.wrap(contact_user.corporate_admin_by_user) + contact_user.corporate_employees_by_user).compact.uniq.map(&:email).map(&:downcase)
    current_user.contacts.select { |x| manager_emails.include? x.emailaddress.downcase }
  end
  
  def remove_corporate_client
    contact = Contact.find(params[:contact_id])
    authorize contact
    user_account = User.find_by(email: contact.try(:emailaddress))
    CorporateService.remove_client_from_admin(client: user_account, admin: current_user)
    flash[:success] = "Client Account was successfully removed."
    redirect_to corporate_accounts_path
  end
  
  private
  
  def remove_client_shares(client)
    return unless client.present?
    Share.where(user: client).each do |client_share|
      next unless user = User.find_by(email: client_share.contact.emailaddress)
      client_share.destroy if client.corporate_user_by_employee?(user) || client.corporate_user_by_admin?(user)
    end
  end

  def add_account_user_to_employee(user)
    CorporateEmployeeAccountUser.create!(:corporate_employee => current_user, :user_account => user)
    corporate_emplooyee_contact = create_corporate_employee_contact_for_user_account(corporate_employee: current_user, user_account: user)
    CorporateAdminService.add_category_share_for_corporate_employee(corporate_employee_contact: corporate_emplooyee_contact, corporate_admin: corporate_owner, user: user)
  end

  def corporate_settings_params
    params.require(:corporate_account_profile).permit(:business_name, :web_address, :street_address, :city,
                                              :zip, :state, :phone_number, :fax_number, :company_logo)
  end

  def user_accounts
    CorporateAdminAccountUser.select { |x| x.corporate_admin == corporate_owner && x.account_type == CorporateAdminAccountUser.client_type }.map(&:user_account)
  end

  def user_account_params
    params.require(:user).permit(:email, :email_confirmation,
                                 user_profile_attributes: [ :first_name, :last_name,
                                                            :two_factor_phone_number,
                                                            :phone_number, :street_address_1,
                                                            :city, :state, :zip ])
  end

  def error_path(action)
    @path = ReturnPathService.error_path(corporate_owner, corporate_owner, params[:controller], action)
    corporate_account_error_breadcrumb_update
    new_account_form_billing_checks if action == :new
  end

  def success_path(path)
    ReturnPathService.success_path(corporate_owner, corporate_owner, path, path)
  end

  def new_account_form_billing_checks
    admin = current_user.corporate_admin ? current_user : (
      current_user.corporate_employee? && current_user.corporate_account_owner)
    stripe_customer = StripeService.ensure_corporate_stripe_customer(user: admin) if admin
    @has_card = !!(stripe_customer && StripeService.customer_card(customer: stripe_customer))
    @is_corporate_employee = current_user.corporate_employee?
  end
end
