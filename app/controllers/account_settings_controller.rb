class AccountSettingsController < AuthenticatedController
  before_action :set_user_profile, only: [:index, :update]
  before_action :set_contacts_shareable, only: [:index, :update]
  
  def index; end

  def update
    respond_to do |format|
      if @user_profile.update_attributes(account_settings_params)
        errors = update_password
        if (errors.nil? && password_change_params[:password].present?) || password_change_params[:password].empty?
          bypass_sign_in(@user)
          format.html { redirect_to account_settings_path, notice: 'Account Settings were successfully updated.' }
          format.json { render :index, status: :updated, location: @user_profile }
        else
          @user_profile.errors.messages.merge!(errors.messages)
          format.html { render :index }
          format.json { render json: @user_profile.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :index }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def update_password
    @user = User.find(current_user.id)
    return nil if @user.update(password_change_params)
    @user.errors
  end
  
  def account_settings_params
    params.require(:user_profile).permit(:mfa_frequency, :photourl, :two_factor_phone_number, primary_shared_with_ids: [])
  end
  
  def password_change_params
    params.require(:user_profile).permit(:password, :password_confirmation)
  end
  
  def set_user_profile
    @user_profile = UserProfile.for_user(current_user)
  end
  
  def set_contacts_shareable
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
  end
end
