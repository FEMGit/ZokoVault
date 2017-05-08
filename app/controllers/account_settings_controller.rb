class AccountSettingsController < AuthenticatedController
  before_action :set_user_profile, only: [:send_code, :update_two_factor_phone,
                                          :verify_code, :account_users, :update_account_users,
                                          :login_settings, :update_login_settings]
  before_action :set_contacts_shareable, only: [:account_users]
  before_action :create_contact_if_not_exists, only: [:update_login_settings, :update_account_users]
  include UserTrafficModule

  def page_name
    case action_name
      when 'account_users'
        "Account Settings - Account Users"
      when 'login_settings'
        "Account Settings - Login Settings"
      when 'manage_subscription'
        "Account Settings - Manage Subscription"
      when 'billing_info'
        "Account Settings - Update Billing Info"
    end
  end

  def account_users; end

  def login_settings; end

  def manage_subscription
    @subscription = StripeSubscription.find_by(user: current_user)
    return unless @subscription.present?
    @plan = StripeSubscription.plan(@subscription.plan_id)
    @customer = Stripe::Customer.retrieve @subscription.customer_id
    @card = @customer[:sources][:data].detect { |x| x[:object] == 'card' }
    @next_invoice_date = DateTime.strptime(Stripe::Invoice.upcoming(:customer => @subscription.customer_id)[:date].to_s, '%s')
    customer_ids = Stripe::Customer.all.select { |i| i.email.downcase == current_user.email.downcase }.map(&:id)
    @invoices = Stripe::Invoice.all.select { |i| customer_ids.include? i[:customer] }
  end

  def invoice_information
    invoice = Stripe::Invoice.retrieve(params[:id])
    customer = Stripe::Customer.retrieve(invoice.customer)
    card = customer[:sources][:data].detect { |x| x[:object] == 'card' }
    html = render_to_string(
      layout: 'pdf_invoice',
      locals: { invoice: invoice, card: card }
      )
    kit = PDFKit.new(html)
    pdf_file = kit.to_pdf
    send_data pdf_file, filename: "#{invoice.receipt_number}_invoice.pdf", type: :pdf, disposition: 'inline'
  end

  def billing_info
    session[:ret_url] = manage_subscription_path
  end

  def update_login_settings
    respond_to do |format|
      if @user_profile.update_attributes(login_settings_params)
        errors = update_password
        if (errors.nil? && password_change_params[:password].present?) || password_change_params[:password].empty?
          bypass_sign_in(@user)
          format.html { redirect_to login_settings_path, flash: { success: 'Login Settings were successfully updated.' } }
          format.json { render :login_settings, status: :updated, location: @user_profile }
        else
          @user_profile.errors.messages.merge!(errors.messages)
          format.html { render :login_settings }
          format.json { render json: @user_profile.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :login_settings }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_account_users
    respond_to do |format|
      if @user_profile.update_attributes(account_users_params)
          format.html { redirect_to account_users_path, flash: { success: 'Account Users were successfully updated.' } }
          format.json { render :account_users, status: :updated, location: @user_profile }
      else
        format.html { render :account_users }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def send_code
    status =
      begin
        MultifactorAuthenticator.new(current_user).send_code_on_number(new_phone)
        :ok
      rescue
        :bad_request
      end

    head status
  end

  def verify_code
    phone_code = login_settings_params[:phone_code]
    verified = MultifactorAuthenticator.new(current_user).verify_code(phone_code)
    status = if verified
               @user_profile.update_attributes(:two_factor_phone_number => new_phone)
               :ok
             else
               :unauthorized
             end
    head status
  end

  def update_payment
    token = params[:stripeToken]
    if token.present?
      customer = StripeService.ensure_stripe_customer(user: current_user)
      source = customer.sources.create(source: token)
      customer.default_source = source.id
      customer.save
    end
    redirect_to session[:ret_url] || first_run_path
  end

  private

  def create_contact_if_not_exists
    contact = Contact.for_user(current_user).find_or_initialize_by(emailaddress: current_user.email)
    contact.update_attributes(
      firstname: @user_profile.first_name,
      lastname: @user_profile.last_name,
      emailaddress: current_user.email,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      user_id: current_user.id,
      user_profile_id: @user_profile.id,
      photourl: account_settings_params[:photourl]
    )
  end

  def update_password
    @user = User.find(current_user.id)
    return nil if @user.update(password_change_params)
    @user.errors
  end

  def account_settings_params
    params.require(:user_profile).permit(:photourl, :phone_code)
  end

  def account_users_params
    params.require(:user_profile).permit(full_primary_shared_with_ids: [], primary_shared_with_ids: [])
  end

  def login_settings_params
    params.require(:user_profile).permit(:mfa_frequency, :phone_code, :two_factor_phone_number)
  end

  def password_change_params
    params.require(:user_profile).permit(:password, :password_confirmation)
  end

  def set_user_profile
    @user_profile = UserProfile.for_user(current_user)
  end

  def new_phone
    login_settings_params[:two_factor_phone_number]
  end

  def set_contacts_shareable
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
  end
end
