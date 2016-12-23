class AccountSettingsController < AuthenticatedController
  before_action :set_user_profile, only: [:index, :update, :send_code, :update_two_factor_phone, :verify_code]
  before_action :set_contacts_shareable, only: [:index, :update]
  before_action :create_contact_if_not_exists, only: [:update]
  
  def index; end

  def update
    respond_to do |format|
      if @user_profile.update_attributes(account_settings_params)
        errors = update_password
        if (errors.nil? && password_change_params[:password].present?) || password_change_params[:password].empty?
          bypass_sign_in(@user)
          format.html { redirect_to account_settings_path, flash: { success: 'Account Settings were successfully updated.' } }
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

  def send_code
    status =
      begin
        MultifactorAuthenticator.new(current_user).send_code_on_number(new_phone)
        :ok
      rescue
        :bad_request
      end

    head status
  end
  
  def verify_code
    phone_code = account_settings_params[:phone_code]
    verified = MultifactorAuthenticator.new(current_user).verify_code(phone_code)
    status = if verified
               @user_profile.update_attributes(:two_factor_phone_number => new_phone, :phone_authentication_skip => false)
               :ok
             else
               :unauthorized
             end
    head status
  end

  def flash_notice
    respond_to do |format|
      format.js { flash[:notice] = "BLABLABLA" }
    end
  end
  
  private

  def create_contact_if_not_exists
    contact = Contact.for_user(current_user).find_or_initialize_by(emailaddress: current_user.email)
    contact.update_attributes(
      firstname: @user_profile.first_name,
      lastname: @user_profile.last_name,
      emailaddress: current_user.email,
      contact_type: nil,
      relationship: 'Account Owner',
      beneficiarytype: nil,
      user_id: current_user.id,
      user_profile_id: @user_profile.id,
      photourl: account_settings_params[:photourl]
    )
  end
  
  def update_password
    @user = User.find(current_user.id)
    return nil if @user.update(password_change_params)
    @user.errors
  end
  
  def account_settings_params
    params.require(:user_profile).permit(:mfa_frequency, :photourl, :phone_code, :two_factor_phone_number, :phone_authentication_skip,
                                         full_primary_shared_with_ids: [], primary_shared_with_ids: [])
  end
  
  def password_change_params
    params.require(:user_profile).permit(:password, :password_confirmation)
  end
  
  def set_user_profile
    @user_profile = UserProfile.for_user(current_user)
  end

  def new_phone
    account_settings_params[:two_factor_phone_number]
  end
  
  def set_contacts_shareable
    contact_service = ContactService.new(:user => current_user)
    @contacts_shareable = contact_service.contacts_shareable
  end
end
