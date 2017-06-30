require 'ostruct'

class AccountSettingsController < AuthenticatedController
  before_action :set_user_profile, only: [:send_code, :update_two_factor_phone,
                                          :verify_code, :account_users, :update_account_users,
                                          :login_settings, :update_login_settings]
  before_action :set_contacts_shareable, only: [:account_users]
  before_action :create_contact_if_not_exists, only: [:update_login_settings, :update_account_users]
  before_action :update_account_users_params, only: [:update_account_users]
  include TutorialsHelper
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

  def phone_setup; end

  def phone_setup_update
    current_user.update_attributes(phone_setup_params)
    redirect_to login_settings_path
  end
  
  def manage_subscription
    @subscription = current_user.current_user_subscription
    return if @subscription.blank? || !@subscription.full?
    customer = current_user.stripe_customer
    source = customer.try(:default_source)
    @card = customer.sources.retrieve(source) if source.present?
    if @subscription.funding.beta?
      @plan = OpenStruct.new(name: 'Beta User - One Year Free')
    else
      upcoming = Stripe::Invoice.upcoming(customer: customer.id)
      @next_invoice_date = DateTime.strptime(upcoming.date.to_s, '%s')
      @next_invoice_amount = upcoming.amount_due
      @invoices = customer.invoices.to_a
      record = @subscription.funding.stripe_subscription_record
      @plan = record.try(:plan)
    end
  end

  def invoice_information
    invoice = Stripe::Invoice.retrieve(params[:id])
    charge  = Stripe::Charge.retrieve(invoice.charge)
    html = render_to_string(
      layout: 'pdf_invoice',
      locals: { invoice: invoice, card: charge.source }
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
        if tutorial_params[:tutorial_name].present?
          tutorial_redirection(format, @user_profile.as_json, 'Vault Co-Owner was successfully updated.' )
        else
          format.html { redirect_to account_users_path, flash: { success: 'Account Users were successfully updated.' } }
          format.json { render :account_users, status: :updated, location: @user_profile }
        end
      else
        tutorial_error_handle("Error saving Vault Co-Owner") && return
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

      fn = ->(err){ flash[:error] = err.message; nil }
      source = StripeHelper.safe_request(on_failure: fn) { customer.sources.create(source: token) }
      (redirect_to (session[:ret_url] || root_path) and return) unless source

      customer.default_source = source.id
      customer.save
      if customer.subscriptions.blank?
        plan = stripe_subscription_params[:plan_id]
        promo = stripe_subscription_params[:promo_code]
        stripe_obj = StripeService.subscribe(
          customer: customer, plan_id: plan, promo_code: promo)
        our_obj = current_user.create_stripe_subscription(
          customer_id: customer.id,
          subscription_id: stripe_obj.id,
          plan_id: plan, promo_code: promo)
        SubscriptionService.create_from_stripe(
          user: current_user, stripe_subscription_object: stripe_obj)
      end
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
      photourl: account_settings_params && account_settings_params[:photourl]
    )
  end

  def update_password
    @user = User.find(current_user.id)
    return nil if @user.update(password_change_params)
    @user.errors
  end

  def update_account_users_params
    return if params[:user_profile].blank?
    params[:user_profile][:primary_shared_with_ids] = Array.wrap(params[:user_profile][:primary_shared_with_ids])
  end

  def tutorial_params
    params.permit(:tutorial_name)
  end

  def account_settings_params
    return nil unless params[:user_profile].present?
    params.require(:user_profile).permit(:photourl, :phone_code)
  end

  def account_users_params
    return {} if params[:user_profile].blank?
    params.require(:user_profile).permit(full_primary_shared_with_ids: [], primary_shared_with_ids: [])
  end

  def login_settings_params
    params.require(:user_profile).permit(:mfa_frequency, :phone_code, :two_factor_phone_number)
  end

  def password_change_params
    params.require(:user_profile).permit(:password, :password_confirmation)
  end

  def phone_setup_params
    params.require(:user).permit(user_profile_attributes: [:two_factor_phone_number])
  end

  def stripe_subscription_params
    params.require(:user
         ).require(:stripe_subscription_attributes
         ).permit(:plan_id, :promo_code)
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
