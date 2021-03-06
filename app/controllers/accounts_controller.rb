class AccountsController < AuthenticatedController
  include UserTrafficModule
  include AccountLockerHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  skip_before_action :redirect_if_free_user
  layout "blank_layout", only: [:setup, :terms_of_service, :phone_setup, :user_name_setup,
                                :login_settings, :user_type, :trial_membership_ended,
                                :trial_membership_update, :trial_questionnaire, :payment,
                                :first_run, :zoku_vault_info, :corporate_user_type, :corporate_logo,
                                :corporate_account_options, :how_billing_works, :billing_types,
                                :corporate_credit_card]
  before_action :set_blank_layout_header_info, only: [:first_run]
  before_action :redirect_to_root_if_setup_complete, only: [:terms_of_service, :terms_of_service_update,
                                                            :user_name_setup, :user_name_setup_update,
                                                            :phone_setup, :phone_setup_update, :login_settings,
                                                            :login_settings_update, :user_type, :user_type_update,
                                                            :corporate_user_type, :corporate_user_type_update,
                                                            :corporate_logo, :corporate_logo_update, :zoku_vault_info,
                                                            :corporate_account_options, :corporate_account_options_update,
                                                            :how_billing_works, :billing_types, :corporate_credit_card]
  before_action :redirect_to_root_unless_corporate_admin, only: [:corporate_user_type, :corporate_user_type_update,
                                                                 :corporate_logo, :corporate_logo_update,
                                                                 :corporate_account_options, :corporate_account_options_update,
                                                                 :how_billing_works, :billing_types, :corporate_credit_card]
  before_action :redirect_to_user_name_update_if_name_empty, only: [:phone_setup, :phone_setup_update, :login_settings,
                                                            :login_settings_update, :user_type, :user_type_update,
                                                            :corporate_user_type, :corporate_user_type_update,
                                                            :corporate_logo, :corporate_logo_update, :zoku_vault_info,
                                                            :corporate_account_options, :corporate_account_options_update,
                                                            :how_billing_works, :billing_types, :corporate_credit_card]
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
    redirect_to lets_get_started_tutorials_path
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
    current_user.save(validate: false)
    redirect_to user_name_setup_account_path and return if current_user.first_name.blank? || current_user.last_name.blank?
    redirect_to zoku_vault_info_account_path
  end
  
  def user_name_setup
    @user = current_user
  end
  
  def user_name_setup_update
    respond_to do |format|
      if current_user.update_attributes(user_params)
        format.html { redirect_to zoku_vault_info_account_path }
      else
        @user = current_user
        format.html { render :user_name_setup, layout: 'blank_layout' }
      end
    end
  end
  
  def zoku_vault_info; end

  def phone_setup
    check_terms_of_service_passed
  end

  def phone_setup_update
    current_user.update_attributes(user_phone_params)
    if current_user.corporate_manager?
      current_user.user_profile.update_attributes(mfa_frequency: 'always')
      current_user.update_attributes(setup_complete: true) unless current_user.corporate_admin
      redirect_to corporate_user_type_accounts_path and return if current_user.corporate_admin
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
    current_user.update_attributes(user_params)
    redirect_to corporate_accounts_path and return if current_user.corporate_employee?
    redirect_to user_type_account_path
  end

  def user_type
    check_phone_setup_passed
    current_user.update(corporate_admin: false)
    if current_user.corporate_user?
      @corporate_admin = current_user.corporate_account_owner
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
        format.html { redirect_to corporate_logo_accounts_path }
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
        format.html { redirect_to corporate_account_options_accounts_path }
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
    redirect_to how_billing_works_accounts_path
  end

  def how_billing_works; end

  def billing_types; end

  def corporate_credit_card
    if !current_user.corporate_credit_card_required
      current_user.update_attributes(setup_complete: true)
      redirect_to corporate_accounts_path 
    end
  end
  
  def user_type_update
    if user_params[:user_type].eql?('free') || current_user.corporate_manager?
      if current_user.corporate_manager?
        MailchimpService.new.subscribe_to_corporate(current_user)
      elsif !current_user.paid?
        MailchimpService.new.subscribe_to_shared(current_user)
      end
      current_user.update_attributes(setup_complete: true)
    elsif user_params[:user_type].eql? 'trial'
      if SubscriptionService.eligible_for_trial?(current_user)
        SubscriptionService.activate_trial(user: current_user)
      end
      current_user.update_attributes(setup_complete: true)
      redirect_to corporate_accounts_path and return if current_user.corporate_employee?
      redirect_to first_run_accounts_path and return
    elsif user_params[:user_type].eql? 'free'
      MailchimpService.new.subscribe_to_shared(current_user) unless current_user.paid?
      current_user.update_attributes(setup_complete: true)
    elsif user_params[:user_type].eql? 'corporate'
      MailchimpService.new.subscribe_to_corporate(current_user)
      current_user.update_attributes(setup_complete: false)
      current_user.update(corporate_admin: true)
      redirect_to corporate_user_type_accounts_path and return
    end
    redirect_to root_path
  end

  def update
    current_user.update_attributes(user_params.merge(setup_complete: true))
    redirect_to session[:ret_url] || first_run_accounts_path
  end

  def show; end

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
  
  # this is only used from layouts/two_factor_phone_setup
  # therefore the current_user should be fully authenticated or in setup
  def send_code
    status = :bad_request if missing_mfa? && current_user.setup_complete
    status ||= begin
      number = two_factor_phone_params[:two_factor_phone_number]
      MultifactorAuthenticator.new(current_user).send_code_on_number(number)
      :ok
    rescue
      :bad_request
    end
    head status
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
    phone_code = mfa_phone_params[:phone_code]
    phone_number = mfa_phone_params[:two_factor_phone_number] ||
                   current_user.user_profile.two_factor_phone_number
    MultifactorAuthenticator.new(current_user).verify_code(
      code: phone_code, phone_number: phone_number
    ).tap do |result|
      if result
        session[:mfa_code_used] = phone_code
        session[:mfa_phone_number] = phone_number
      else
        session[:mfa_code_used] = nil
        session[:mfa_phone_number] = nil
      end
    end
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

  def user_phone_params
    params.require(:user).permit(user_profile_attributes: [:two_factor_phone_number])
  end

  def user_params
    params.require(:user).permit(
      :user_type,
      user_profile_attributes: [
        :first_name,
        :last_name,
        :signed_terms_of_service,
        :phone_number_mobile,
        :two_factor_phone_number,
        :mfa_frequency,
        :phone_code,
        security_questions_attributes: [:question, :answer],
      ]
    )
  end
  
  def mfa_phone_params
    params.require(:user).require(:user_profile_attributes
      ).permit(:phone_code, :two_factor_phone_number)
  end

  def stripe_promo_params
    params.require(:user
         ).require(:stripe_subscription_attributes
         ).permit(:promo_code)
  end

  def questionnaire_params
    params.require(:questionnaire)
  end
  
  def redirect_to_root_unless_corporate_admin
    redirect_to root_path unless current_user.corporate_admin
  end

  def redirect_to_root_if_setup_complete
    redirect_to root_path if current_user.setup_complete
  end

  def redirect_to_user_name_update_if_name_empty
    redirect_to user_name_setup_account_path if current_user.first_name.blank? || current_user.last_name.blank?
  end
end
