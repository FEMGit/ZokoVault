class MfasController < AuthenticatedController
  skip_before_filter :mfa_verify!, :redirect_if_free_user
  before_filter :not_verified!
  layout "blank_layout", only: [:show]

  def show
    MultifactorAuthenticator.new(current_user).send_code
  rescue
    @phone_number_error = true
  end

  def create
    phone_code = phone_params[:phone_code]

    if MultifactorAuthenticator.new(current_user).verify_code(phone_code)
      session[:mfa] = true
      redirect_to root_path
    else
      redirect_to mfa_path
    end
  end

  def resend_code
    render :json => {:success => true} if MultifactorAuthenticator.new(current_user).send_code
  end

  private

  def phone_params
    params.permit(:phone_code)
  end

  def not_verified!
    if session[:mfa]
      redirect_to root_path
    end
  end
end
