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
    
    if user.blank?
      non_existing_user = FailedEmailLoginAttempt.find_or_create_by(email: resource.email)
      non_existing_user.increment!(:failed_attempts) if non_existing_user.locked_at.blank?
      failed_attempts_count = non_existing_user.failed_attempts
    else
      failed_attempts_count = user.failed_attempts
    end
    
    attempts_remaining = Session::FAILED_ATTEMPTS_LIMIT - failed_attempts_count
    if attempts_remaining <= 0
      if non_existing_user.present?
        non_existing_user.update_attribute(:locked_at, Time.now)
      end
      flash[:alert] = ("Invalid Email or password.<br>Account locked, unlock instructions have been emailed to you.").html_safe
    elsif failed_attempts_count > 0
      flash[:alert] = ("Invalid Email or password.<br>#{attempts_remaining} attempts remaining.").html_safe
    end
  end
end
