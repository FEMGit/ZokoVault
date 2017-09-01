class SessionsController < Devise::SessionsController
  include BackPathHelper
  skip_before_action :redirect_if_user_terms_of_service_empty, only: [:destroy]
  auto_session_timeout_actions
  
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    set_alert_message
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  def create
    try_set_failed_attempts_to_zero
    store_location
    super
    flash.delete(:notice)
  end
  
  def timeout
    flash[:alert] = Session::SESSION_EXPIRED_ALERT_MESSAGE
    session[:session_timeout_back_path] = back_path
    redirect_to new_user_session_path
  end

  private
  
  def try_set_failed_attempts_to_zero
    user = User.find_by(email: login_params[:email])
    if user.present? && user.corporate_user? && !user.corporate_invitation_sent?
      user.update(:failed_attempts => 0)
    end
  end
  
  def login_params
    params.require(:user)
  end
  
  def set_alert_message
    return if resource.blank? || resource.email.blank?
    user = User.find_by(email: resource.email)
    return if user.blank?
    flash[:alert] = ErrorMessages::INVALID_EMAIL_OR_PASSWORD
  end
  
  def store_location
    user = User.find_by(email: login_params[:email])
    if user.present? && session[:session_timeout_back_path].present?
      store_location_for(user, session[:session_timeout_back_path])
      session[:session_timeout_back_path] = nil
    end
  end
end
