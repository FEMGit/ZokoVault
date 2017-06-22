class PasswordsController < Devise::PasswordsController
  def create
    user = User.find_by(email: resource_params[:email])
    email_sent_message = "If an account was found, instructions will be sent to your email address"
    
    if user.blank? || (user.corporate_user? && !user.corporate_invitation_sent?)
      self.resource = User.new
    else
      self.resource = resource_class.send_reset_password_instructions(resource_params)
    end
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = email_sent_message
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      if resource.email.present?
        resource.errors.messages.clear
        flash[:notice] = email_sent_message
      end
      respond_with(resource, location: after_sending_reset_password_instructions_path_for(resource_name))
    end
  end
end
