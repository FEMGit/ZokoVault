class AccountsController < AuthenticatedController
  include UserTrafficModule
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  skip_before_action :redirect_if_free_user
  layout "blank_layout", only: [:setup, :terms_of_service, :phone_setup,
                                :login_settings, :user_type, :trial_membership_ended,
                                :trial_membership_update, :trial_questionnaire, :payment,
                                :first_run]
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
    unless SubscriptionService.trial_was_used?(current_user)
      SubscriptionService.activate_trial(user: current_user)
    else
      redirect_to root_path
    end
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
    current_user.update_attributes(user_params_except_subscription)
    redirect_to phone_setup_account_path
  end

  def phone_setup
    check_terms_of_service_passed
  end

  def phone_setup_update
    current_user.update_attributes(user_params_except_subscription)
    redirect_to login_settings_account_path
  end

  def login_settings
    check_phone_setup_passed
  end

  def login_settings_update
    current_user.update_attributes(user_params_except_subscription.merge(setup_complete: true))
    redirect_to user_type_account_path
  end

  def user_type
    check_phone_setup_passed
  end

  def user_type_update
    if user_params[:user_type].eql? 'trial'
      unless SubscriptionService.trial_was_used?(current_user)
        SubscriptionService.activate_trial(user: current_user)
      end
      redirect_to(first_run_path) and return
    elsif user_params[:user_type].eql? 'free'
      MailchimpService.new.subscribe_to_shared(current_user)
    end
    redirect_to(root_path)
  end

  def update
    update_params = free_account? ? user_params_except_subscription : user_params
    current_user.update_attributes(update_params.merge(setup_complete: true))
    redirect_to session[:ret_url] || first_run_path
  end

  def show; end

  def send_code
    current_user.update_attributes(user_params.except(:stripe_subscription_attributes))
    status =
      begin
        MultifactorAuthenticator.new(current_user).send_code
        :ok
      rescue
        :bad_request
      end

    head status
  end

  def subscriptions
    render json: StripeSubscription.plans.to_json.html_safe
  end

  def yearly_subscription
    render json: Array.wrap(StripeSubscription.yearly_plan).to_json.html_safe
  end

  def apply_promo_code
    coupon = Stripe::Coupon.retrieve(user_params[:stripe_subscription_attributes][:promo_code])
    if coupon.valid
      render json: coupon
    else
      render json: { :message => 'Coupon Exprired', :status => 500 }
    end
  end

  def verify_code
    current_user.attributes = user_params
    phone_code = current_user.user_profile.phone_code
    verified = MultifactorAuthenticator.new(current_user).verify_code(phone_code)
    status = if verified
               session[:mfa] = true
               :ok
             else
               :unauthorized
             end
    head status
  end

  private

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

  def account_params
    params.require(:user).permit(:free_account)
  end

  def skip_param
    params.permit(:skip)
  end

  def user_params_except_subscription
    user_params.except(:stripe_subscription_attributes)
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
      ],
      stripe_subscription_attributes: [
        :plan_id,
        :promo_code])
  end

  def questionnaire_params
    params.require(:questionnaire)
  end

  def free_account?
    account_params[:free_account].eql? 'true'
  end
end
