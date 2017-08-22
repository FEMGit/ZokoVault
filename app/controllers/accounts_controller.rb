class AccountsController < AuthenticatedController
  include UserTrafficModule
  include AccountLockerHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  skip_before_action :redirect_if_free_user
  layout "blank_layout", only: [:setup, :terms_of_service, :phone_setup,
                                :login_settings, :user_type, :trial_membership_ended,
                                :trial_membership_update, :trial_questionnaire, :payment,
                                :first_run, :zoku_vault_info, :corporate_user_type, :corporate_logo,
                                :corporate_account_options, :how_billing_works, :billing_types,
                                :corporate_credit_card]
  before_action :set_blank_layout_header_info, only: [:first_run]
  skip_before_action :redirect_if_user_terms_of_service_empty, only: [:terms_of_service_update]

  def page_name
    case action_name
      when 'first_run'
        "Account - First Run"
      when 'upgrade'
        "Account - Upgrade (Product Comparison)"
      when 'terms_of_service'
        "Account Setup - Terms of Service"
      when 'phone_setup'
        "Account Setup - Phone"
      when 'login_settings'
        "Account Setup - Login Setting"
      when 'user_type'
        "Account Setup - User Type"
    end
  end

  def setup; end

  def first_run
    if SubscriptionService.eligible_for_trial?(current_user)
      SubscriptionService.activate_trial(user: current_user)
    end
    redirect_to tutorials_lets_get_started_path
  end

  def payment
    session[:ret_url] = root_path
  end

  def upgrade; end

  def trial_membership_ended; end

  def trial_membership_update; end

  def trial_questionnaire
    @deny_reasons = ["Too expensive", "I didn't use the site", "Features did not match my needs"]
  end

  def trial_questionnaire_update
    if skip_param[:skip].eql? false.to_s
      send_message
    end

    current_user.current_user_subscription_marker.try(:delete)
    MailchimpService.new.subscribe_to_shared(current_user)
    redirect_to shares_path
  end

  def send_message
    reasons = questionnaire_params[:reasons].try(:keys)
    feedback = questionnaire_params[:feedback]

    @message = Message.new(
      name: current_user.name,
      email: current_user.email,
      message_content: { reasons: reasons, feedback: feedback },
      phone_number: current_user.two_factor_phone_number)

    if @message.valid? && @message.message_content.length > 0
      MessageMailer.membership_ended(@message).deliver
    end
  end

  def terms_of_service; end

  def terms_of_service_update
    current_user.update_attributes(user_params)
    redirect_to zoku_vault_info_account_path
  end

  def zoku_vault_info; end

  def phone_setup
    check_terms_of_service_passed
  end

  def phone_setup_update
    current_user.update_attributes(user_params)
    if current_user.corporate_employee?
      current_user.user_profile.update_attributes(mfa_frequency: 'always')
      current_user.update_attributes(setup_complete: true)
      redirect_to user_type_account_path
    else
      redirect_to login_settings_account_path
    end
  end

  def login_settings
    check_phone_setup_passed
    redirect_to user_type_account_path if current_user.corporate_employee?
  end

  def login_settings_update
    current_user.update_attributes(user_params.merge(setup_complete: true))
    redirect_to corporate_accounts_path and return if current_user.corporate_employee?
    redirect_to user_type_account_path
  end

  def user_type
    check_phone_setup_passed
    if current_user.corporate_user?
      @corporate_admin = user.corporate_account_owner
      @corporate_profile = @corporate_admin.corporate_account_profile
    end
  end

  def corporate_user_type
    corporate_admin = User.find_by(id: current_user.try(:id))
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: corporate_admin)
    @corporate_profile.contact_type = 'Advisor' if @corporate_profile.contact_type.blank?
    @corporate_profile.save
  end

  def corporate_user_type_update
    corporate_admin = User.find_by(id: current_user.try(:id))
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: corporate_admin)
    @corporate_profile.company_information_required!
    respond_to do |format|
      if @corporate_profile.update(company_information_params)
        format.html { redirect_to corporate_logo_path }
      else
        format.html { render :corporate_user_type, layout: 'blank_layout' }
        format.json { render json: @corporate_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def corporate_logo
    corporate_admin = User.find_by(id: current_user.try(:id))
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: corporate_admin)
  end

  def corporate_logo_update
    corporate_admin = User.find_by(id: current_user.try(:id))
    @corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: corporate_admin)
    respond_to do |format|
      if @corporate_profile.update(company_information_params)
        format.html { redirect_to corporate_account_options_path }
      else
        format.html { render :corporate_logo, layout: 'blank_layout' }
        format.json { render json: @corporate_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def corporate_account_options; end

  def corporate_account_options_update
    current_user.update_attributes(:corporate_admin => true)
    corporate_admin = User.find_by(id: current_user.try(:id))
    corporate_profile = CorporateAccountProfile.find_or_initialize_by(user: corporate_admin)
    current_user.user_profile.update_attributes(:mfa_frequency => UserProfile.mfa_frequencies[:always])
    MessageMailer.corporate_account_information(corporate_profile, corporate_options_params).deliver
    redirect_to how_billing_works_path
  end

  def how_billing_works; end

  def billing_types; end

  def corporate_credit_card; end

  def user_type_update
    if user_params[:user_type].eql? 'trial'
      if SubscriptionService.eligible_for_trial?(current_user)
        SubscriptionService.activate_trial(user: current_user)
      end
      current_user.update_attributes(setup_complete: true)
      redirect_to corporate_accounts_path and return if current_user.corporate_employee?
      redirect_to first_run_path and return
    elsif user_params[:user_type].eql? 'free'
      MailchimpService.new.subscribe_to_shared(current_user) unless current_user.paid?
      current_user.update_attributes(setup_complete: true)
    elsif user_params[:user_type].eql? 'corporate'
      MailchimpService.new.subscribe_to_shared(current_user) unless current_user.paid?
      current_user.update_attributes(setup_complete: false)
      redirect_to corporate_user_type_path and return
    end
    redirect_to root_path
  end

  def update
    current_user.update_attributes(user_params.merge(setup_complete: true))
    redirect_to session[:ret_url] || first_run_path
  end

  def show; end

  def send_code
    status =
      begin
        MultifactorAuthenticator.new(current_user).send_code_on_number(two_factor_phone_params[:two_factor_phone_number])
        :ok
      rescue
        :bad_request
      end

    head status
  end

  def subscriptions
    render json: StripeSubscription.active_plans.to_json.html_safe
  end

  def yearly_subscription
    render json: Array.wrap(StripeSubscription.yearly_plan).to_json.html_safe
  end

  def apply_promo_code
    promo  = stripe_promo_params[:promo_code]
    coupon = StripeHelper.safe_request { Stripe::Coupon.retrieve(promo) } if promo.present?

    if coupon && coupon.valid
      render json: coupon
    elsif coupon
      render json: { :message => 'Coupon Expired', :status => 500 }
    else
      render json: { :message => 'Coupon Not Found', :status => 500 }
    end
  end

  def mfa_verify_code
    status = if code_verified?
               if shared_user_params.present?
                 session[:mfa_shared] = true
               else
                 session[:mfa] = true
               end
               current_user.update(:mfa_failed_attempts => 0)
               :ok
             else
               mfa_failed_attempts_limit_reached? && lock_account &&
                 (render json: { errors: 'Account locked' }, status: :unauthorized) and return
               :unauthorized
             end
    head status
  end

  private

  def code_verified?
    current_user.attributes = user_params
    phone_code = current_user.user_profile.phone_code
    MultifactorAuthenticator.new(current_user).verify_code(phone_code)
  end

  def set_blank_layout_header_info
    @header_information = true
  end

  def check_terms_of_service_passed
    redirect_to terms_of_service_account_path unless current_user.user_profile.signed_terms_of_service_at.present?
  end

  def check_phone_setup_passed
    redirect_to_path =
      if current_user.user_profile.signed_terms_of_service_at.blank?
        terms_of_service_account_path
      elsif current_user.user_profile.two_factor_phone_number.blank?
        phone_setup_account_path
      end
    redirect_to redirect_to_path if redirect_to_path.present?
  end

  def company_information_params
    params.require(:corporate_account_profile).permit(:business_name, :web_address, :street_address, :city,
                                              :zip, :state, :phone_number, :fax_number, :company_logo)
  end

  def corporate_options_params
    params.require(:corporate_account_options).permit(:provide_to, services: [])
  end

  def shared_user_params
    return nil unless params[:shared_user_id].present?
    params[:shared_user_id]
  end

  def skip_param
    params.permit(:skip)
  end

  def two_factor_phone_params
    params.require(:user).require(:user_profile_attributes).permit(:two_factor_phone_number)
  end

  def user_params
    params.require(:user).permit(
      :user_type,
      user_profile_attributes: [
        :signed_terms_of_service,
        :phone_number_mobile,
        :two_factor_phone_number,
        :mfa_frequency,
        :phone_code,
        security_questions_attributes: [:question, :answer],
      ]
    )
  end

  def stripe_promo_params
    params.require(:user
         ).require(:stripe_subscription_attributes
         ).permit(:promo_code)
  end

  def questionnaire_params
    params.require(:questionnaire)
  end

end
