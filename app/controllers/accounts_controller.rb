class AccountsController < AuthenticatedController
  before_action :generate_stripe_token, only: [:update]
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  layout "blank_layout", only: [:setup]

  def setup; end
  
  def first_run; end

  def update
    update_params = free_account? ? user_params.except(:subscription_attributes) : user_params
    current_user.update_attributes(update_params.merge(setup_complete: true))
    redirect_to session[:ret_url] || first_run_path
  end
  
  def card_validation
    begin
      StripeService.token(params[:number], params[:exp_month], params[:exp_year], params[:cvc])
      render :nothing => true
    rescue Stripe::CardError => e
      body = e.json_body
      err = body[:error]
      render json: err[:message], status: 500
    end
  end
  
  def generate_stripe_token
    unless free_account?
      stripe_token = StripeService.token(card_params[:subscription_attributes][:card_number],
                                         card_params[:subscription_attributes][:expiration_month],
                                         card_params[:subscription_attributes][:expiration_year],
                                         card_params[:subscription_attributes][:cvc])
      params[:user][:subscription_attributes][:stripe_token] = stripe_token.id
    end
  end

  def show; end

  def send_code
    current_user.update_attributes(user_params.except(:subscription_attributes))
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
    render json: Subscription.plans.to_json.html_safe
  end

  def apply_promo_code
    coupon = Stripe::Coupon.retrieve(user_params[:subscription_attributes][:promo_code])
    render json: coupon
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

  def account_params
    params.require(:user).permit(:free_account)
  end

  def card_params
    params.require(:user).permit(
      subscription_attributes: [
        :name_on_card, 
        :card_number,
        :expiration_month,
        :expiration_year,
        :cvc])
  end

  def user_params
    params.require(:user).permit(
      user_profile_attributes: [
        :signed_terms_of_service,
        :phone_number_mobile,
        :two_factor_phone_number,
        :mfa_frequency,
        :phone_code,
        security_questions_attributes: [:question, :answer],
      ],
      subscription_attributes: [
        :name_on_card, 
        :card_number,
        :stripe_token,
        :plan_id,
        :promo_code])
  end

  def free_account?
    account_params[:free_account].eql? 'true'
  end
end
