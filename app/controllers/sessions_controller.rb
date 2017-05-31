class SessionsController < Devise::SessionsController
  skip_before_action :redirect_if_user_terms_of_service_empty, only: [:destroy]
  
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    set_alert_message
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  def create
    super
    flash.delete(:notice)
  end

  private
  
  def set_alert_message
    return if resource.blank? || resource.email.blank?
    user = User.find_by(email: resource.email)
    return if user.blank?
    
    flash[:alert] = "Invalid Email or password. Please try again."
  end
end
