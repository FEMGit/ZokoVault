class SessionsController < Devise::SessionsController
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
    
    failed_attempts_count = user.failed_attempts
    attempts_remaining = Session::FAILED_ATTEMPTS_LIMIT - failed_attempts_count
    if attempts_remaining.eql? 0
      flash[:alert] = ("Invalid Email or password.<br>Account locked, unlock instructions have been emailed to you.").html_safe
    elsif failed_attempts_count > 0
      flash[:alert] = ("Invalid Email or password.<br>#{attempts_remaining} attempts remaining.").html_safe
    end
  end
end
