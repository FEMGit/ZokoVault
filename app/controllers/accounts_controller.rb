class AccountsController < AuthenticatedController

  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  layout "blank_layout", only: [:setup]

  def setup; end
  
  def first_run; end

  def update
    current_user.update_attributes(user_params.merge(setup_complete: true))
    redirect_to first_run_path
  end

  def show; end

  def send_code
    current_user.update_attributes(user_params)
    status =
      begin
        MultifactorAuthenticator.new(current_user).send_code
        :ok
      rescue
        :bad_request
      end

    head status
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

  def user_params
    params.require(:user).permit(
      user_profile_attributes: [
        :signed_terms_of_service,
        :phone_number_mobile,
        :two_factor_phone_number,
        :mfa_frequency,
        :phone_code,
        security_questions_attributes: [:question, :answer]
      ])
  end
end
