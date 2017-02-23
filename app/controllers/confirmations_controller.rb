class ConfirmationsController < Devise::ConfirmationsController
  def create
    email_sent_message = "If an account was found, a recovery email will be sent to your email address"
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = email_sent_message
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      if resource.email.present?
        resource.errors.messages.clear
        flash[:notice] = email_sent_message
      end
      respond_with(resource, location: confirmation_path(resource_name))
    end
  end
  
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message :notice, :confirmed
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      resource.errors.messages.clear
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
  
  protected

  def after_confirmation_path_for(*)
    email_confirmed_path
  end
end
