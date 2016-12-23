class PasswordsController < Devise::PasswordsController
  def create
    email_sent_message = "If an account was found, instructions will be sent to your email address"
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = email_sent_message
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      if resource.email.present?
        resource.errors.messages.clear
        flash[:notice] = email_sent_message
      end
      respond_with(resource, location: new_password_path(resource_name))
    end
  end
end
