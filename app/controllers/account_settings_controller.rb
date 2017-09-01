require 'ostruct'

class AccountSettingsController < AuthenticatedController
  skip_before_filter :complete_setup!, only: [:store_corporate_payment]
  before_action :set_corporate_paid
  before_action :set_user_profile, only: [:send_code, :update_two_factor_phone,
                                          :verify_code, :account_users, :update_account_users,
                                          :login_settings, :update_login_settings]
  before_action :set_contacts_shareable, only: [:account_users]
  before_action :create_contact_if_not_exists, only: [:update_login_settings, :update_account_users]
  before_action :update_account_users_params, only: [:update_account_users]
  before_action :redirect_to_manage_subscription_if_corporate_client, only: [:billing_info, :update_payment,  :cancel_subscription,
                                                                             :cancel_subscription_update, :update_subscription_information]
  include TutorialsHelper
  include UserTrafficModule
  include StripeHelper

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

  def cancel_subscription
    customer = current_user.stripe_customer
    @next_invoice_date = next_invoice(customer).try(:date)
    redirect_to manage_subscription_path unless @next_invoice_date.present?
  end

  def cancel_subscription_update
    return unless StripeService.cancel_subscription(user: current_user)
    flash[:success] = "ZokuVault subscription was successfully canceled."
    redirect_to manage_subscription_path
  end

  def update_subscription_information
    @card = customer_card
    @corporate_update = corporate_update? ? params[:corporate] : nil
  end

  def phone_setup_update
    current_user.update_attributes(phone_setup_params)
    redirect_to login_settings_path
  end

  def manage_subscription
    session[:ret_url] = manage_subscription_path
    @subscription = current_user.current_user_subscription
    return if @subscription.blank? || !@subscription.full?
    if @subscription.funding.beta?
      @plan = OpenStruct.new(name: 'Beta User - One Year Free')
      @card = customer_card
    else
      record = @subscription.funding.stripe_subscription_record
      set_subscription_cancelled(record)
      @plan = record.try(:plan)
      stripe_customer = stripe_customer_lookup(current_user, @corporate_paid)
      @next_invoice = next_invoice(stripe_customer)
      if current_user.corporate_client? && @corporate_paid
        @corporate = true
        admin = current_user.corporate_account_owner
        @company_name = admin.corporate_account_profile.try(:business_name)
      else
        personal_invoices = stripe_customer ? stripe_customer.invoices.to_a : []
        @corporate_invoices = StripeService.corporate_stripe_customers_invoices_history(user: current_user)
        @invoices = personal_invoices + @corporate_invoices
        @card = customer_card
      end
    end
  end
  
  def customer_card
    customer = stripe_customer_lookup(current_user, @corporate_paid)
    StripeService.customer_card(customer: customer) if customer.present?
  end

  def set_subscription_cancelled(stripe_record)
    return if stripe_record.blank? || stripe_record.fetch.blank?
    if stripe_record.fetch.cancel_at_period_end
      pend = stripe_record.fetch.current_period_end
      @subscription_end_time = DateTime.strptime(pend.to_s, '%s')
      @subscription_cancelled = true
    else
      @subscription_cancelled = false
    end
  end

  # TODO normalize representation & remove this
  def stripe_customer_lookup(user, corporate_paid = nil)
    corporate_paid = corporate_paid.nil? ? user.paid_by_corporate_admin? : corporate_paid
    if user.corporate_admin
      StripeService.ensure_corporate_stripe_customer(user: user)
    elsif user.corporate_user? && corporate_paid
      StripeService.ensure_corporate_stripe_customer(user: user.corporate_account_owner)
    else
      user.stripe_customer
    end
  end

  def invoice_information
    if params[:id].blank?
      flash[:error] = "Error occured while receiving an invoice."
      redirect_to back_path
      return
    end
    invoice = Stripe::Invoice.retrieve(params[:id])
    charge  = Stripe::Charge.retrieve(invoice.charge) if invoice.try(:charge).present?
    user_paid_for = 
      if params[:corporate].present? && params[:corporate].eql?('true')
        user_name_by_subscription_id(invoice.try(:subscription))
      else
        nil
      end
    html = render_to_string(
      layout: 'pdf_invoice',
      locals: { invoice: invoice, card: charge.try(:source), user_paid_for: user_paid_for }
    )
    kit = PDFKit.new(html)
    pdf_file = kit.to_pdf
    send_data pdf_file, filename: "#{invoice.receipt_number}_invoice.pdf", type: :pdf, disposition: 'inline'
  end

  def billing_info
    session[:ret_url] = billing_info_path
    @card = customer_card
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
      begin
        if @user_profile.update_attributes(account_users_params)
          if tutorial_params[:tutorial_name].present?
            tutorial_redirection(format, @user_profile.as_json)
          else
            format.html { redirect_to account_users_path, flash: { success: 'Account Users were successfully updated.' } }
            format.json { render :account_users, status: :updated, location: @user_profile }
          end
        else
          tutorial_error_handle("Error saving Vault Co-Owner") && return
          format.html { render :account_users }
          format.json { render json: @user_profile.errors, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotSaved
        set_contacts_shareable
        if account_users_params[:full_primary_shared_with_ids].present?
          full_primary_shared_with_contact = Contact.for_user(current_user).where(:id => account_users_params[:full_primary_shared_with_ids])
          invalid_contacts = full_primary_shared_with_contact.select { |x| !x.valid? }
          if invalid_contacts.present?
            @user_profile.errors[:contact_validation_error] = invalid_contacts.map(&:name)
            flash[:error] = 'Some of the contacts you are trying to save have invalid data. Please fix them and try again.'
          end
        end
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

  def store_corporate_payment
    token = params[:stripeToken]
    if token.present?
      customer = StripeService.ensure_corporate_stripe_customer(user: current_user)
      (redirect_to (back_path || root_path) and return) unless update_customer_information(customer, token)
    end
    current_user.update_attributes(setup_complete: true)
    redirect_to corporate_accounts_path
  end

  def update_customer_information(customer, token)
    return nil unless customer.present?
    fn = ->(err){ flash[:error] = err.message; nil }
    source = StripeHelper.safe_request(on_failure: fn) { customer.sources.create(source: token) }
    return nil unless source

    customer.default_source = source.id
    customer.save
  end

  def update_payment
    token = params[:stripeToken]
    card = customer_card
    if token.present? || card.present?
      customer = StripeService.stripe_customer(user: current_user, corporate_update: corporate_update?)
      
      unless ((token.present? && update_customer_information(customer, token)) || card.present?)
        redirect_to (session[:ret_url] || root_path) and return
      end
      if !(current_user.paid? && !current_user.trial?) && customer.subscriptions.blank? && stripe_subscription_params.present? &&
          stripe_subscription_params[:plan_id].present? 
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
        redirect_to account_settings_thank_you_for_subscription_path(plan) and return
      end
    end
    redirect_to redirect_from_payment_page_path
  end

  def thank_you_for_subscription
    @plan_duration = thank_you_subscription_plan_duration
    if corporate_client_id = params[:corporate_client_id]
      @corporate_client = User.find_by(id: corporate_client_id)
      @customer_id = StripeService.customer_id(user: @corporate_client)
      redirect_to corporate_accounts_path unless current_user.corporate_manager? && @plan_duration
                                                 @corporate_client.corporate_user_by_manager?(current_user)
    else
      @customer_id = StripeService.customer_id(user: current_user)
      redirect_to manage_subscription_path unless @plan_duration
    end
  end

  private

  def thank_you_subscription_plan_duration
    StripeSubscription.plan_duration_name(plan_id: params[:plan_id])
  end

  def set_corporate_paid
    @corporate_paid = current_user.paid_by_corporate_admin?
  end

  def redirect_to_manage_subscription_if_corporate_client
    redirect_to manage_subscription_path if current_user && current_user.corporate_client? && @corporate_paid
  end

  def redirect_from_payment_page_path
    if session[:ret_url].present?
      return manage_subscription_path if request.referer.eql? billing_info_url
      session[:ret_url]
    else
      first_run_path
    end
  end

  def corporate_update?
    return nil unless params[:corporate].present?
    params[:corporate].eql? 'corporate'
  end

  Invoice = Struct.new(:date, :amount)

  def next_invoice(customer)
    return if customer.blank? || customer.id.blank?
    upcoming = Stripe::Invoice.upcoming(customer: customer.id)
    Invoice.new(
      DateTime.strptime(upcoming.date.to_s, '%s'),
        upcoming.amount_due)
  rescue Stripe::InvalidRequestError
    nil
  end

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
    return nil unless params[:user] && params[:user][:stripe_subscription_attributes]
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
