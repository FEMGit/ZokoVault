class MfasController < AuthenticatedController
  skip_before_filter :mfa_verify!, :save_return_to_path, :redirect_if_free_user
  before_filter :not_verified!
  layout "blank_layout", only: [:show]

  def show
    MultifactorAuthenticator.new(current_user).send_code
    @shared_user_id = params[:shared_user_id]
  rescue
    @phone_number_error = true
  end

  def resend_code
    if MultifactorAuthenticator.new(current_user).send_code
      render status: 200, json: {success: true}
    else
      render status: 422, json: {success: false}
    end
  end

  private

  def not_verified!
    if params[:shared_user_id].present? && session[:mfa_shared]
      redirect_to dashboard_shared_view_path(params[:shared_user_id])
    elsif params[:shared_user_id].blank? && session[:mfa]
      redirect_to root_path
    end
  end
end
