class UnlocksController < Devise::UnlocksController
  def create
    email_sent_message = "If an account was found, a recovery email will be sent to your email address"
    self.resource = resource_class.send_unlock_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = email_sent_message
      respond_with({}, location: after_sending_unlock_instructions_path_for(resource))
    else
      if resource.email.present?
        resource.errors.messages.clear
        flash[:notice] = email_sent_message
      end
      respond_with(resource, location: after_sending_unlock_instructions_path_for(resource_name))
    end
  end

  def show
    self.resource = resource_class.unlock_access_by_token(params[:unlock_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message :notice, :unlocked
      respond_with_navigational(resource) { redirect_to after_unlock_path_for(resource) }
    else
      resource.errors.messages.clear
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end
