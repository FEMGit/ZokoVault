class PasswordsController < Devise::PasswordsController
  include BackPathHelper
  
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
    
    sleep(0.075 + SecureRandom.random_number(175) / 1000.0) if user.blank?
  end
  
  
  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      errors = resource.errors
      respond_with resource do |format|
        if errors && errors.messages[:reset_password_token] &&
            errors.messages[:reset_password_token].include?('Incorrect Format')
          format.html { redirect_to password_link_expired_path(corporate_password_update?) }
        elsif create_new_invitation? && reset_token_params[:reset_password_token].present?
          format.html { render :action => :create_new_invitation}
        else
          format.html { render :action => :edit}
        end
      end
    end
  end
  
  def create_new_invitation
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
  end
  
  private
    
  def reset_token_params
    params.require(:user).permit(:reset_password_token)
  end
  
  def create_new_invitation?
    params[:create_new_invitation].present? &&
      (params[:create_new_invitation].eql? 'true')
  end
end
